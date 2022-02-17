//
//  ScheduleViewModel.swift
//  imink
//
//  Created by Jone Wang on 2022/2/15.
//

import Foundation
import Combine
import os

class ScheduleViewModel: ObservableObject {
    @Published var schedules: Schedules?
    @Published var loadStatus: ProgressStatus = .success
    
    private var cancelBag = Set<AnyCancellable>()
    private var requestBag = Set<AnyCancellable>()
    
    init() {
        reload()
        
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.localFilter()
            }
            .store(in: &cancelBag)
    }
    
    private func localFilter() {
        if var schedules = schedules {
            let now = Date()
            schedules.regular = schedules.regular.filter { $0.endTime > now }
            schedules.gachi = schedules.gachi.filter { $0.endTime > now }
            schedules.league = schedules.league.filter { $0.endTime > now }
            
            if schedules.regular.count != self.schedules!.regular.count ||
                schedules.gachi.count != self.schedules!.gachi.count ||
                schedules.league.count != self.schedules!.league.count {
                self.schedules = schedules
                
                reload()
            }
        }
    }
    
    func reload() {
        requestBag = Set<AnyCancellable>()
        
        localFilter()
        
        loadStatus = .loading
        
        AppAPI.schedules
            .request()
            .decode(type: Schedules.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    os_log("API Error: [schedules] \(error.localizedDescription)")
                    self?.loadStatus = .fail
                }
            } receiveValue: { [weak self] schedules in
                self?.loadStatus = .success
                self?.schedules = schedules
            }
            .store(in: &requestBag)
    }
}
