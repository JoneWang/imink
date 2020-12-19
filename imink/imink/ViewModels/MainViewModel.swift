//
//  MainViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation
import SwiftUI
import Combine
import os

class MainViewModel: ObservableObject {    
    @Published var currentUser = AppUserDefaults.shared.user
    @Published var clientToken = AppUserDefaults.shared.clientToken

    private var cancelBag = Set<AnyCancellable>()

    init() {
        if clientToken != nil {
            // If logined update user
            requestUserInfo()
        }
    }
    
    func requestUserInfo() {
        iminkAPIProvider.requestPublisher(.me())
            .map(User.self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // FIXME: token invalid
//                    if case APIError.clientTokenInvalid = error {
//                        self.currentUser = nil
//                        self.clientToken = nil
//                    } else {
                        // TODO: Popping error view
                        os_log("API Error: [/me] \(error.localizedDescription)")
//                    }
                }
            } receiveValue: { user in
                // Save new user information
                AppUserDefaults.shared.user = user
            }
            .store(in: &cancelBag)
    }
}
