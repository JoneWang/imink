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
    
    init() {
        reload()
    }
    
    func reload() {
        cancelBag = Set<AnyCancellable>()
        
        loadStatus = .loading
        
        schedules = nil
        
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
            .store(in: &cancelBag)
    }
}
