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
    
    @Published var error: Error? = nil
    
    private var cancelBag = Set<AnyCancellable>()
    private var syncCancelBag = Set<AnyCancellable>()
    
    init() {
        isLogined = AppUserDefaults.shared.sessionToken != nil
        
        if isLogined {
            checkIksmSession()
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
    
    func checkIksmSession() {
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
                       let sessionToken = AppUserDefaults.shared.sessionToken {
                        return NSOHelper.getIKsmSession(sessionToken: sessionToken)
                            .map { _ in Void() }
                            .eraseToAnyPublisher()
                    } else {
                        return Future<Void, Error> { promise in
                            promise(.success(Void())) // dummy
                        }
                        .eraseToAnyPublisher()
                    }
                })
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        if case NSOError.sessionTokenInvalid = error {
                            AppUserDefaults.shared.sessionToken = nil
                            self.error = error
                        } else {
                            // TODO: Other errors
                            os_log("API Error: [records or getIKsmSession] \(error.localizedDescription)")
                        }
                    }
                } receiveValue: { _ in
                    // TODO:
                }
                .store(in: &cancelBag)
        } else {
            guard let sessionToken = AppUserDefaults.shared.sessionToken else {
                return
            }
            
            NSOHelper.getIKsmSession(sessionToken: sessionToken)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        if case NSOError.sessionTokenInvalid = error {
                            AppUserDefaults.shared.sessionToken = nil
                            self.error = error
                        } else {
                            // TODO: Other errors
                            os_log("API Error: [records or getIKsmSession] \(error.localizedDescription)")
                        }
                    }
                } receiveValue: { _ in
                    // TODO:
                }
                .store(in: &cancelBag)
        }
    }
}
