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
        case none
        case loading
        case loginSuccess
    }
    
    @Published var status: Status = .none
    @Published var clientToken: String = ""
    
    // Nintendo account login
    @Published var codeVerifier: String?
    @Published var loginError: Error? = nil
    
    var cancelBag = Set<AnyCancellable>()
}

/// Nintendo account login
extension LoginViewModel {
    
    func loginFlow(sessionTokenCode: String) {
        guard let codeVerifier = codeVerifier else {
            return
        }
        
        status = .loading
        NSOHelper.logIn(codeVerifier: codeVerifier, sessionTokenCode: sessionTokenCode)
            .sink { (completion) in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.loginError = error
                    os_log("API [Login] Error: \(error.localizedDescription)")
                }
            } receiveValue: { sessionToken, records in
                IksmSessionManager.shared.refresh()
                AppUserDefaults.shared.sessionToken = sessionToken
                AppUserDefaults.shared.sp2PrincipalId = records.records.player.principalId
                self.status = .loginSuccess
            }
            .store(in: &cancelBag)
    }
}
