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
        AppDatabase.shared.removeAllRecords()
        AppDatabase.shared.removeAllJobs()
        
        isLogin = AppUserDefaults.shared.user != nil
        
        if !isLogin {
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

// MARK: Request

extension TabBarViewModel {
    
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
