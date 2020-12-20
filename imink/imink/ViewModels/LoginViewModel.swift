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
import Moya

class LoginViewModel: ObservableObject {
    enum Status {
        case waitTypeToken
        case loading
        case loginSuccess
    }
    
    @Published var useClientToken = false
    @Published var useNintendoAccount = false
    
    @Published var status: Status? = .waitTypeToken
    @Published var clientToken: String = ""
    
    // Nintendo account login
    @Published var loginInfo: NintendoLoginInfo?
    @Published var isLoading = false
    
    var cancelBag = Set<AnyCancellable>()
    
    init() {
        requestNintendoLoginURL()
        
        $useNintendoAccount
            .sink { [weak self] use in
                if !use {
                    self?.requestNintendoLoginURL()
                }
            }
            .store(in: &cancelBag)
    }
    
    func login() {
        status = .loading
        
        iminkAPIProvider.requestPublisher(.me(clientToken: clientToken))
            .map(User.self, using: JSONDecoder.convertFromSnakeCase)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // TODO: Popping error view
                    os_log("API Error: [/me] \(error.localizedDescription)")
                    self.status = .waitTypeToken
                }
            } receiveValue: { [weak self] user in
                guard let `self` = self else { return }
                
                // Save Client Token
                print(self.clientToken)
                
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
        iminkAPIProvider.requestPublisher(.loginURL)
            .map(NintendoLoginInfo.self, using: JSONDecoder.convertFromSnakeCase)
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
    
    func signIn(_ info: String) -> AnyPublisher<User, MoyaError> {
        isLoading = true
        
        let target = AppAPI.signIn(
            authCodeVerifier: loginInfo!.authCodeVerifier,
            loginInfo: info)
        let signIn = iminkAPIProvider.requestPublisher(target)
            .map(User.self, using: JSONDecoder.convertFromSnakeCase)
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
