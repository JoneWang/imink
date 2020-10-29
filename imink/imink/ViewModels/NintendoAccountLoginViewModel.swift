//
//  NintendoAccountLoginViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/10/29.
//

import Foundation
import Foundation
import SwiftUI
import Combine
import os

class NintendoAccountLoginViewModel: ObservableObject {
    
    @Published var loginInfo: NintendoLoginInfo?
    @Published var isLoading = false
    
    var cancelBag = Set<AnyCancellable>()
    
    init() {
        AppAPI.loginURL
            .request()
            .decode(type: NintendoLoginInfo.self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    os_log("API Error: [/account/login_url] \(error.localizedDescription)")
                }
            } receiveValue: { loginInfo in
                self.loginInfo = loginInfo
            }
            .store(in: &cancelBag)
    }
    
    func signIn(_ info: String) -> AnyPublisher<User, Error> {
        isLoading = true
        
        return AppAPI.signIn(
            authCodeVerifier: loginInfo!.authCodeVerifier,
            loginInfo: info
        )
        .request()
        .decode(type: User.self)
        .eraseToAnyPublisher()
    }
    
}
