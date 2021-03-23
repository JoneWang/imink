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
    
    @Published var isLogined = false
    @Published var autoRefresh = true
    
    private var cancelBag = Set<AnyCancellable>()
    private var syncCancelBag = Set<AnyCancellable>()
    
    init() {
        isLogined = AppUserDefaults.shared.loginToken != nil
        
        if isLogined {
            // Update user if logged in
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

// MARK: Request

extension TabBarViewModel {
    
    func requestUserInfo() {
        if Splatoon2API.sessionIsValid {
            Splatoon2API.records
                .request()
                .receive(on: DispatchQueue.main)
                .compactMap { (data: Data) -> Void in
                    // Cache
                    AppUserDefaults.shared.splatoon2RecordsData = data
                    return Void()
                }
                .catch({ error -> AnyPublisher<Void, Error> in
                    if case APIError.iksmSessionInvalid = error,
                       let loginToken = AppUserDefaults.shared.loginToken,
                       let naUser = AppUserDefaults.shared.naUser {
                        return NSOHelper.getIksmSession(loginToken: loginToken, naUser: naUser)
                            .map { _ in Void() }
                            .eraseToAnyPublisher()
                    } else {
                        return Future<Void, Error> { promise in
                            promise(.success(Void())) // dummy
                        }
                        .eraseToAnyPublisher()
                    }
                })
                .sink { _ in
                    // TODO:
                } receiveValue: { _ in
                    // TODO:
                }
                .store(in: &cancelBag)
        } else {
            guard let loginToken = AppUserDefaults.shared.loginToken,
                  let naUser = AppUserDefaults.shared.naUser else {
                return
            }
            
            NSOHelper.getIksmSession(loginToken: loginToken, naUser: naUser)
                .sink { _ in
                    // TODO:
                } receiveValue: { _ in
                    // TODO:
                }
                .store(in: &cancelBag)
        }
    }
}
