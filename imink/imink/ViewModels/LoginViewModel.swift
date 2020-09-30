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
    
    @Published var status: Status? = .waitTypeToken
    @Published var clientToken: String = ""
    @Published var loginUser: User? = nil
    
    var cancelBag = Set<AnyCancellable>()
    
    func login() {
        status = .loading
        
        AppAPI.me(clientToken: clientToken)
            .request()
            .decode(type: User.self)
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
                
                self.loginUser = user
                self.status = .loginSuccess
            }
            .store(in: &cancelBag)
    }
}
