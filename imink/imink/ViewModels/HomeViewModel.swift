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

struct Today {
    var victoryCount: Int = 0
    var defeatCount: Int = 0
    var killCount: Int = 0
    var assistCount: Int = 0
    var deathCount: Int = 0
}

class HomeViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    
    @Published var syncTotalCount = 0
    @Published var recordTotalCount = 0
    
    @Published var today: Today = Today()
    
    @Published var resetHour: Int = 2
    @Published var vdWithLast500: [Bool] = []
    
    @Published var activeFestivals: ActiveFestivals?
    
    @Published var isLoading: Bool = false
    
    private var todayStartTime: Date? {
        let now = Date()
        
        guard var startTime = Calendar.current.date(bySettingHour: resetHour, minute: 0, second: 0, of: now) else {
            return nil
        }
        
        if now.get(.hour) < resetHour {
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
    
    private var schedulesPublisher: AnyPublisher<ProgressStatus, Never>
    private var salmonRunSchedulesPublisher: AnyPublisher<ProgressStatus, Never>
    
    init(schedulesLoadStatus: AnyPublisher<ProgressStatus, Never>, salmonRunSchedulesLoadStatus: AnyPublisher<ProgressStatus, Never>) {
        schedulesPublisher = schedulesLoadStatus
        salmonRunSchedulesPublisher = salmonRunSchedulesLoadStatus
        
        let isLogined = AppUserDefaults.shared.sessionToken != nil
        updateLoginStatus(isLogined: isLogined)
    }
    
    func updateLoginStatus(isLogined: Bool) {
        cancelBag = Set<AnyCancellable>()
        syncCancelBag = Set<AnyCancellable>()
        
        self.isLogined = isLogined
        
        let currentTimeZone = (TimeZone.current.secondsFromGMT() / 3600)
        resetHour = (currentTimeZone % 2 == 0) ? 2 : 3
        
        if (isLogined) {
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
                .assign(to: \.recordTotalCount, on: self)
                .store(in: &cancelBag)
            
            $recordTotalCount
                .map { _ in
                    guard let todayStartTime = self.todayStartTime else {
                        return Today()
                    }
                    
                    let (todayVictoryCount, todayDefeatCount) = AppDatabase.shared.victoryAndDefeatCount(startTime: todayStartTime)
                    let (todayKillCount, todayAssistCount, todayDeathCount) = AppDatabase.shared.killAssistAndDeathCount(startTime: todayStartTime)
                    return Today(
                        victoryCount: todayVictoryCount,
                        defeatCount: todayDefeatCount,
                        killCount: todayKillCount,
                        assistCount: todayAssistCount,
                        deathCount: todayDeathCount
                    )
                }
                .assign(to: \.today, on: self)
                .store(in: &cancelBag)
            
            $recordTotalCount
                .map { _ in AppDatabase.shared.vdWithLast500() }
                .assign(to: \.vdWithLast500, on: self)
                .store(in: &cancelBag)
            
            startSyncCountPublisher()
        } else {
            recordTotalCount = 0
            recordTotalCount = 0
            today = Today()
            vdWithLast500 = []
        }
        
        updateSchedules()
    }
    
    /// Get schedules
    func updateSchedules() {
        isLoading = true
        
        if isLogined {
            let activeFestivals = Splatoon2API.activeFestivals
                .request()
                .decode(type: ActiveFestivals.self)
                .receive(on: DispatchQueue.main)
                .map { festivals -> ActiveFestivals? in festivals }
                .catch { error -> Just<ActiveFestivals?> in
                    os_log("API Error: [activeFestivals] \(error.localizedDescription)")
                    return Just<ActiveFestivals?>(nil)
                }
                .share()
            
            activeFestivals
                .assign(to: \.activeFestivals, on: self)
                .store(in: &cancelBag)
            
            // All finish
            Publishers.Zip3(schedulesPublisher, salmonRunSchedulesPublisher, activeFestivals)
                .map { _ in false }
                .assign(to: \.isLoading, on: self)
                .store(in: &cancelBag)
        } else {
            // All finish
            Publishers.Zip(schedulesPublisher, salmonRunSchedulesPublisher)
                .map { _ in false }
                .assign(to: \.isLoading, on: self)
                .store(in: &cancelBag)
        }
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
    }
}
