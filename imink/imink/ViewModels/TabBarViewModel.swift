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

class TabBarViewModel: ObservableObject {
        
    @Published var unsynchronizedBattleIds: [String] = []
        
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
        
        requestResults {
            if !self.autoRefresh { return }
            
            if self.unsynchronizedBattleIds.count == 0 {
                NotificationCenter.default.post(
                    name: .isLoadingRealTimeBattleResult,
                    object: false
                )
            }
            
            // Next request after delayed for 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.startRealTimeDataLoop()
            }
        }
    }
    
    func requestResults(finished: (() -> Void)? = nil) {
        Splatoon2API.battleInformation
            .request() // Not decode
            .decode(type: BattleOverview.self)
            .receive(on: DispatchQueue.main)
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
            } receiveValue: { battleOverview in
                let battleIds = battleOverview.results.map { $0.battleNumber }
                                
                if let firstId = battleIds.first,
                   self.unsynchronizedBattleIds.first != firstId {
                    let unsynchronizedIds = AppDatabase.shared.unsynchronizedBattleIds(with: battleIds).sorted { $0 < $1 }
                    if unsynchronizedIds.count == 0 {
                        NotificationCenter.default.post(
                            name: .isLoadingRealTimeBattleResult,
                            object: false
                        )
                    }
                    
                    self.unsynchronizedBattleIds = unsynchronizedIds
                } else {
                    NotificationCenter.default.post(
                        name: .isLoadingRealTimeBattleResult,
                        object: false
                    )
                }
            }
            .store(in: &cancelBag)
    }
    
    func syncDetails() {
        syncCancelBag = Set<AnyCancellable>()
        
        $unsynchronizedBattleIds
            .compactMap { $0.first }
//            .breakpoint(receiveSubscription: { subscription in
//                return false
//            }, receiveOutput: { value in
//                print(value)
//                return false
//            }, receiveCompletion: { completion in
//                return false
//            })
            .flatMap { self.requestBattleDetail(battleNumber: $0) }
            .catch { error -> Just<Data> in
                os_log("API Error: [splatoon2/battles/id] \(error.localizedDescription)")
                return Just<Data>(Data())
            }
            .sink { [weak self] data in
                guard let `self` = self else { return }
                AppDatabase.shared.saveBattle(data: data)
                
                if self.unsynchronizedBattleIds.count > 0 {
                    self.unsynchronizedBattleIds.removeFirst()
                }
                
                if self.unsynchronizedBattleIds.count == 0 {
                    NotificationCenter.default.post(name: .recordSyncDetailFinished, object: nil)
                    NotificationCenter.default.post(
                        name: .isLoadingRealTimeBattleResult,
                        object: false
                    )
                }
            }
            .store(in: &syncCancelBag)
    }
    
}

// MARK: Request

extension TabBarViewModel {
    
    func requestBattleDetail(battleNumber: String) -> AnyPublisher<Data, APIError>  {
        Splatoon2API.result(battleNumber: battleNumber)
            .request() // Not decode
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
