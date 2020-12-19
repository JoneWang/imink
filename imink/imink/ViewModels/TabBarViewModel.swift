//
//  TabBarViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/10/1.
//

import Foundation
import Combine
import os
import WidgetKit
import Moya
import CXMoya

class TabBarViewModel: ObservableObject {
    
    @Published var databaseRecords: [DBRecord] = []
    
    @Published var isLoadingDetail = false
    
    @Published var isLogin = false
    @Published var autoRefresh = true
    
    private var cancelBag = Set<AnyCancellable>()
    private var syncCancelBag = Set<AnyCancellable>()
    
    init() {
        $autoRefresh
            .filter { $0 }
            .sink { [weak self] _ in
                self?.startRealTimeDataLoop()
            }
            .store(in: &cancelBag)
        
        $autoRefresh
            .sink { [weak self] _ in
                self?.syncDetails()
            }
            .store(in: &cancelBag)
        
        $isLogin.assign(to: &$autoRefresh)
        
        isLogin = AppUserDefaults.shared.user != nil
        
        if AppUserDefaults.shared.clientToken != nil {
            // If logined update user
            requestUserInfo()
        }
        
        // Check language and refresh widget
        let currentLanguage = AppUserDefaults.shared.currentLanguage
        if let code = Bundle.main.preferredLocalizations.last {
            if code != currentLanguage {
                AppUserDefaults.shared.currentLanguage = code
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
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
//                    if case APIError.authorizationError = error {
                        // iksm_session invalid
                        // TODO: Recapture iksm_session
//                    } else {
                        // TODO: Other errors
                        os_log("API Error: [splatoon2/results] \(error.localizedDescription)")
//                    }
                }
            } receiveValue: { data in
                // Save original records json to database
                try! AppDatabase.shared.saveSampleBattlesData(data) { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    // Restart data synchronization
                    if self.databaseRecords.filter({ !$0.isDetail }).count > 0 && !self.isLoadingDetail {
                        // Trigger detail request
                        Just<[DBRecord]>(self.databaseRecords)
                            .assign(to: &self.$databaseRecords)
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
    func syncDetails() {
        syncCancelBag = Set<AnyCancellable>()
        
        // Database records publisher
        AppDatabase.shared.records()
            .catch { error -> Just<[DBRecord]> in
                os_log("Database Error: [records] \(error.localizedDescription)")
                return Just<[DBRecord]>([])
            }
            .assign(to: \.databaseRecords, on: self)
            .store(in: &syncCancelBag)
        
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
            .map { [weak self] record -> DBRecord in
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
            .store(in: &syncCancelBag)
    }
    
}

// MARK: Request

extension TabBarViewModel {
    
    func requestBattleOverview() -> AnyPublisher<Data, MoyaError>  {
        sn2Provider.requestPublisher(.battleInformation)
            .receive(on: DispatchQueue.main)
            .map(\.data)
            .eraseToAnyPublisher()
    }
    
    func requestBattleDetail(battleNumber: String) -> AnyPublisher<Data, MoyaError>  {
        sn2Provider.requestPublisher(.result(battleNumber: battleNumber))
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func requestUserInfo() {
        AppAPI.me()
            .request()
            .decode(type: User.self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if case APIError.clientTokenInvalid = error {
                        self.isLogin = false
                    } else {
                        // TODO: Popping error view
                        os_log("API Error: [/me] \(error.localizedDescription)")
                    }
                }
            } receiveValue: { user in
                // Save new user information
                AppUserDefaults.shared.user = user
            }
            .store(in: &cancelBag)
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
