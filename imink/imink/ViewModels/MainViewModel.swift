//
//  InkAppViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/6/4.
//

import Foundation
import Combine
import os
import WidgetKit

class MainViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    @Published var showTokenErrorAlert: Bool = false
    
    private var cancelBag = Set<AnyCancellable>()
    private var syncCancelBag = Set<AnyCancellable>()
    
    init() {
        // Check language and refresh widget
        let currentLanguage = AppUserDefaults.shared.currentLanguage
        if let code = Bundle.main.preferredLocalizations.last {
            if code != currentLanguage {
                AppUserDefaults.shared.currentLanguage = code
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        
        getConfig()
    }
}

// MARK: Request

extension MainViewModel {
    
    func getConfig() {
        AppAPI.config
            .request()
            .decode(type: AppConfig.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
            }, receiveValue: { config in
                AppUserDefaults.shared.nsoVersion = config.nsoVersion
            })
            .store(in: &cancelBag)
    }
    
    func checkIksmSession() {
        if IksmSessionManager.shared.isValid {
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
                        return NSOAuthorization().getIKsmSession(sessionToken: sessionToken)
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
                            self.showTokenErrorAlert = true
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
            IksmSessionManager.shared.renew(launch: true)
        }
    }
}
