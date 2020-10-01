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
    
    var totalKillCount: Int {
        AppDatabase.shared.totalKillCount()
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
        
        self.startSyncCountPublisher()
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
