//
//  TabBarViewModel.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import Foundation
import Combine
import os

class TabBarViewModel: ObservableObject {
    
    @Published var databaseRecords: [Record] = []
    
    @Published var isLoadingDetail = false
    
    @Published var isLogin = false
    @Published var autoRefresh = true
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        // Database records publisher
        AppDatabase.shared.records()
            .catch { error -> Just<[Record]> in
                os_log("Database Error: [records] \(error.localizedDescription)")
                return Just<[Record]>([])
            }
            .assign(to: &$databaseRecords)
        
        // Synchronizing the record where first isDetail is false
        $databaseRecords
            .compactMap { $0.first(where: { !$0.isDetail }) }
            .breakpoint(receiveSubscription: { subscription in
                    return false
                }, receiveOutput: { value in
                    print(value.battleNumber)
                    return false
                }, receiveCompletion: { completion in
                    return false
                })
            .map { [weak self] record -> Record in
                self?.isLoadingDetail = true
                return record
            }
            .flatMap { self.requestBattleDetail(battleNumber: $0.battleNumber) }
            .catch { error -> Just<Data> in
                os_log("API Error: [splatoon2/battles/id] \(error.localizedDescription)")
                return Just<Data>(Data())
            }
            .sink { [weak self] data in
                guard let `self` = self else { return }
                self.updateRecordDetail(data)
                
                if self.databaseRecords.filter({ !$0.isDetail }).count == 0 {
                    self.isLoadingDetail = false
                    NotificationCenter.default.post(name: .recordSyncDetailFinished, object: nil)
                }
            }
            .store(in: &cancelBag)
        
        $autoRefresh
            .filter { $0 }
            .sink { [weak self] _ in
                self?.startRealTimeDataLoop()
            }
            .store(in: &cancelBag)
        
        $isLogin.assign(to: &$autoRefresh)
        
        isLogin = AppUserDefaults.shared.user != nil
    }
}

// MARK: Automatic data synchronization

extension TabBarViewModel {
    
    func startRealTimeDataLoop() {
        NotificationCenter.default.post(
            name: .isLoadingRealTimeBattleResult,
            object: true
        )
        
        syncResultsToDatabase {
            NotificationCenter.default.post(
                name: .isLoadingRealTimeBattleResult,
                object: false
            )
            
            if !self.autoRefresh { return }
            
            // Next request after delayed for 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.startRealTimeDataLoop()
            }
        }
    }
    
    func syncResultsToDatabase(finished: (() -> Void)? = nil) {
        requestBattleOverview()
            .sink { completion in
                finished?()
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if case APIError.authorizationError = error {
                        // iksm_session invalid
                        // TODO: Recapture iksm_session
                    } else {
                        // TODO: Other errors
                        os_log("API Error: [splatoon2/results] \(error.localizedDescription)")
                    }
                }
            } receiveValue: { data in
                // Save original records json to database
                try! AppDatabase.shared.saveSampleBattlesData(data) { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    // Restart data synchronization
                    if self.databaseRecords.filter({ !$0.isDetail }).count > 0 && !self.isLoadingDetail {
                        // Trigger detail request
                        Just<[Record]>(self.databaseRecords)
                            .assign(to: &self.$databaseRecords)
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
}

// MARK: Request

extension TabBarViewModel {
    
    func requestBattleOverview() -> AnyPublisher<Data, APIError>  {
        Splatoon2API.battleInformation
            .request() // Not decode
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func requestBattleDetail(battleNumber: String) -> AnyPublisher<Data, APIError>  {
        Splatoon2API.result(battleNumber: battleNumber)
            .request() // Not decode
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

// MARK: Database

extension TabBarViewModel {
    
    func updateRecordDetail(_ data: Data) {
        guard let detail = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
        ) as? [String: AnyObject] else {
            return
        }
        
        try! AppDatabase.shared.saveDetail(detail)
    }
    
}
