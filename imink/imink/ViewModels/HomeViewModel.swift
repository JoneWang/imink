//
//  HomeViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/10/1.
//

import Foundation
import Combine
import os

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

class HomeViewModel: ObservableObject {
    
    @Published var syncTotalCount = 0
    @Published var synchronizedCount = 0
    @Published var recordTotalCount = 0
    @Published var schedules: Schedules?
    @Published var salmonRunSchedules: SalmonRunSchedules?
    @Published var activeFestivals: ActiveFestivals?
    @Published var isLoading: Bool = false
    
    var vdWithLast500: [Bool] {
        AppDatabase.shared.vdWithLast500()
    }
    
    var todayVictoryAndDefeatCount: (Int, Int) {
        guard let todayStartTime = todayStartTime else { return (0, 0)}
        return AppDatabase.shared.victoryAndDefeatCount(startTime: todayStartTime)
    }
    
    var todayKillAssistAndDeathCount: (Int, Int, Int) {
        guard let todayStartTime = todayStartTime else { return (0, 0, 0)}
        return AppDatabase.shared.killAssistAndDeathCount(startTime: todayStartTime)
    }
    
    private var todayStartTime: Date? {
        let now = Date()
        
        guard var startTime = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: now) else {
            return nil
        }
        
        if now.get(.hour) < 3 {
            guard let tomorrow3Clock = Calendar.current.date(byAdding: .day, value: -1, to: startTime) else {
                return nil
            }
            
            startTime = tomorrow3Clock
        }
        
        return startTime
    }
    
    private var cancelBag = Set<AnyCancellable>()
    private var syncCancelBag: Set<AnyCancellable>!
    
    private var lastSyncTime = Date()
    
    init() {
        NotificationCenter.default
            .publisher(for: .recordSyncDetailFinished)
            .sink { [weak self] _ in
                self?.lastSyncTime = Date()
                self?.startSyncCountPublisher()
            }
            .store(in: &cancelBag)
        
        AppDatabase.shared.totalCount()
            .catch { error -> Just<Int> in
                os_log("Database Error: [totalCount] \(error.localizedDescription)")
                return Just<Int>(0)
            }
            .assign(to: &$recordTotalCount)
        
        updateSchedules()
        
        startSyncCountPublisher()
    }
    
    /// Get schedules
    func updateSchedules() {
        isLoading = true
        
        let battleSchedules = Splatoon2API.schedules
            .request()
            .decode(type: Schedules.self)
            .receive(on: DispatchQueue.main)
            .map { schedules -> Schedules? in schedules }
            .catch { error -> Just<Schedules?> in
                os_log("API Error: [schedules] \(error.localizedDescription)")
                return Just<Schedules?>(nil)
            }
            
        battleSchedules
            .assign(to: &$schedules)
        
        let salmonRunSchedules = Splatoon2API.salmonRunSchedules
            .request()
            .decode(type: SalmonRunSchedules.self)
            .receive(on: DispatchQueue.main)
            .map { schedules -> SalmonRunSchedules? in schedules }
            .catch { error -> Just<SalmonRunSchedules?> in
                os_log("API Error: [salmonRunSchedules] \(error.localizedDescription)")
                return Just<SalmonRunSchedules?>(nil)
            }
            
        salmonRunSchedules
            .assign(to: &$salmonRunSchedules)
        
        let activeFestivals = Splatoon2API.activeFestivals
            .request()
            .decode(type: ActiveFestivals.self)
            .receive(on: DispatchQueue.main)
            .map { festivals -> ActiveFestivals? in festivals }
            .catch { error -> Just<ActiveFestivals?> in
                os_log("API Error: [activeFestivals] \(error.localizedDescription)")
                return Just<ActiveFestivals?>(nil)
            }
            
        activeFestivals
            .assign(to: &$activeFestivals)
        
        // All finish
        Publishers.Zip3(battleSchedules, salmonRunSchedules, activeFestivals)
            .map { _ in false }
            .assign(to: &$isLoading)
    }
    
    func startSyncCountPublisher() {
        syncCancelBag = Set<AnyCancellable>()
        
        AppDatabase.shared.currentSyncTotalCount(lastSyncTime: lastSyncTime)
            .catch { error -> Just<Int> in
                os_log("Database Error: [currentSyncTotalCount] \(error.localizedDescription)")
                return Just<Int>(0)
            }
            .sink { [weak self] count in
                self?.syncTotalCount = count
            }
            .store(in: &syncCancelBag)
        
        AppDatabase.shared.currentSynchronizedCount(lastSyncTime: lastSyncTime)
            .catch { error -> Just<Int> in
                os_log("Database Error: [currentSynchronizedCount] \(error.localizedDescription)")
                return Just<Int>(0)
            }
            .sink { [weak self] count in
                self?.synchronizedCount = count
            }
            .store(in: &syncCancelBag)
    }
    
}
