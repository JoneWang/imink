//
//  HomeViewModel.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import Foundation
import Combine
import os

class HomeViewModel: ObservableObject {
    
    @Published var syncTotalCount = 0
    @Published var synchronizedCount = 0
    @Published var recordTotalCount = 0
    @Published var schedules: SP2Schedules?
    @Published var salmonRunSchedules: SP2SalmonRunSchedules?
    @Published var isLoading: Bool = false
    
    var recordCountForLastMonthChartData: [(String, Double)] {
        let databaseData = AppDatabase.shared.recordCountForPerDay()
        
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.month = -1
        guard let oneMonthAgoDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return [] }
        let components = Calendar.current.dateComponents([Calendar.Component.day], from: oneMonthAgoDate, to: currentDate)
        let days = components.day ?? 0
        
        var data = [(String, Double)]()
        for i in 0..<days {
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: oneMonthAgoDate) else { continue }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            let dateString = formatter.string(from: date)
            formatter.dateFormat = "dd"
            let dayString = formatter.string(from: date)
            
            if let count = databaseData[dateString] {
                data.append((dayString, Double(count)))
            } else {
                data.append((dayString, 0))
            }
        }
        
        return data
    }
    
    var kdForLastMonthChartData: [(String, Double)] {
        let databaseData = AppDatabase.shared.kdForPerDay()
        
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.month = -1
        guard let oneMonthAgoDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) else { return [] }
        let components = Calendar.current.dateComponents([Calendar.Component.day], from: oneMonthAgoDate, to: currentDate)
        let days = components.day ?? 0
        
        var data = [(String, Double)]()
        for i in 0..<days {
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: oneMonthAgoDate) else { continue }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd"
            let dateString = formatter.string(from: date)
            formatter.dateFormat = "dd"
            let dayString = formatter.string(from: date)
            
            if let kd = databaseData[dateString] {
                data.append((dayString, Double(kd)))
            } else {
                data.append((dayString, 0))
            }
        }
        
        return data
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
        
        $schedules
            .map { _ in false }
            .assign(to: &$isLoading)
        
        $schedules
            .map { _ in false }
            .assign(to: &$isLoading)
        
        updateSchedules()
        
        startSyncCountPublisher()
    }
    
    /// Get schedules
    func updateSchedules() {
        isLoading = true
        
        let battleSchedules = Splatoon2API.schedules
            .request()
            .decode(type: SP2Schedules.self)
            .receive(on: DispatchQueue.main)
            .map { schedules -> SP2Schedules? in schedules }
            .catch { error -> Just<SP2Schedules?> in
                os_log("API Error: [schedules] \(error.localizedDescription)")
                return Just<SP2Schedules?>(nil)
            }
            
        battleSchedules
            .assign(to: &$schedules)
        
        let salmonRunSchedules = Splatoon2API.salmonRunSchedules
            .request()
            .decode(type: SP2SalmonRunSchedules.self)
            .receive(on: DispatchQueue.main)
            .map { schedules -> SP2SalmonRunSchedules? in schedules }
            .catch { error -> Just<SP2SalmonRunSchedules?> in
                os_log("API Error: [salmonRunSchedules] \(error.localizedDescription)")
                return Just<SP2SalmonRunSchedules?>(nil)
            }
            
        salmonRunSchedules
            .assign(to: &$salmonRunSchedules)
        
        // All finish
        Publishers.Zip(battleSchedules, salmonRunSchedules)
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
