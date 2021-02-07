//
//  LaunchViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import Foundation
import SwiftUI
import Combine
import os

class LoginViewModel: ObservableObject {
    enum Status {
        case waitTypeToken
        case loading
        case loginSuccess
    }
    
    @Published var useNintendoAccount = false
    
    @Published var status: Status? = .waitTypeToken
    @Published var clientToken: String = ""
    
    // Nintendo account login
    @Published var loginInfo: NintendoLoginInfo?
    @Published var isLoading = false
    
    var cancelBag = Set<AnyCancellable>()
    
    init() {
        requestNintendoLoginURL()
    }
    
    func login() {
        status = .loading
        
        AppAPI.me(clientToken: clientToken)
            .request()
            .decode(type: User.self)
            .receive(on: DispatchQueue.main)
            .flatMap { user -> AnyPublisher<User, Error> in
                Splatoon2API.nicknameAndIcon(id: user.sp2PrincipalId, iksmSession: user.iksmSession)
                    .request()
                    .decode(type: NicknameAndIcon.self)
                    .receive(on: DispatchQueue.main)
                    .map { _ in user }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                guard let `self` = self else { return }

                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // TODO: Popping error view
                    os_log("API Error: (login) \(error.localizedDescription)")
                    self.status = .waitTypeToken
                }
            } receiveValue: { [weak self] user in
                guard let `self` = self else { return }

                // Save Client Token
                AppUserDefaults.shared.clientToken = self.clientToken
                AppUserDefaults.shared.user = user

                self.status = .loginSuccess
            }
            .store(in: &cancelBag)
    }
}

/// Nintendo account login
extension LoginViewModel {
    
    func requestNintendoLoginURL() {
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
        
        let signIn = AppAPI.signIn(
            authCodeVerifier: loginInfo!.authCodeVerifier,
            loginInfo: info
        )
        .request()
        .decode(type: User.self)
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
        signIn.sink { _ in } receiveValue: { [weak self] user in
            guard let `self` = self else { return }
            
            AppUserDefaults.shared.clientToken = user.clientToken
            AppUserDefaults.shared.user = user
            
            self.status = .loginSuccess
        }
        .store(in: &cancelBag)
        
        return signIn
    }
    
}
