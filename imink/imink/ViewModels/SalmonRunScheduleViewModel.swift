//
//  SalmonRunScheduleViewModel.swift
//  imink
//
//  Created by Jone Wang on 2022/2/15.
//

import Foundation
import Combine
import os

class SalmonRunScheduleViewModel: ObservableObject {
    @Published var schedules: [SalmonRunSchedules.Schedule] = []
    @Published var loadStatus: ProgressStatus = .success
    
    public var currentIsFirstPage: Bool { currentPage == firstPage }
    
    private var currentPage = 1
    private var firstPage = 1
    private var canLoadMorePages = true
    
    private var cancelBag = Set<AnyCancellable>()
    private var requestBag = Set<AnyCancellable>()
    
    init() {
        reload()
        
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.localReload()
            }
            .store(in: &cancelBag)
    }
    
    private func localReload() {
        let now = Date()
        let schedules = schedules.filter { $0.endTime > now }
        if schedules.count != self.schedules.count {
            self.schedules = schedules
        }
    }
    
    func reload() {
        if schedules.count > 0 {
            localReload()
        } else {
            load(page: 1)
        }
    }
    
    func reloadNextPage() {
        load(page: currentPage + 1)
    }
    
    func loadNextPageIfNeeded(currentItem item: SalmonRunSchedules.Schedule) {
        if loadStatus == .loading { return }
        
        let thresholdIndex = schedules.index(schedules.endIndex, offsetBy: -3)
        if schedules.firstIndex(where: { $0.startTime == item.startTime }) == thresholdIndex {
            load(page: currentPage + 1)
        }
    }
    
    private func load(page: Int = 1) {
        requestBag = Set<AnyCancellable>()
        
        loadStatus = .loading
        
        AppAPI.salmonRunSchedules(page: page)
            .request()
            .decode(type: SalmonRunSchedules.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    os_log("API Error: [schedules] \(error.localizedDescription)")
                    self.loadStatus = .fail
                }
            } receiveValue: { [weak self] schedules in
                guard let `self` = self else { return }
                
                self.loadStatus = .success
                let schedules = schedules.details +
                    schedules.schedules.filter { s in !schedules.details.contains { $0.$startTime == s.$startTime } }
                
                if schedules.count > 0 {
                    self.currentPage = page
                }
                
                if self.currentIsFirstPage {
                    self.schedules = schedules
                } else {
                    self.schedules = self.schedules + schedules
                }
            }
            .store(in: &requestBag)
    }
}
