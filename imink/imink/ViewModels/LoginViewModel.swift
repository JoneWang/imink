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
    let loginUrl: URL
    let codeVerifier: String
    @Published var loginError: Error? = nil
    
    var cancelBag = Set<AnyCancellable>()
    
    init() {
        let codeVerifier = NSOHash.urandom(length: 32).base64EncodedString
        let authorizeAPI = NSOAPI.authorize(codeVerifier: codeVerifier)
        
        let url = authorizeAPI.baseURL.appendingPathComponent(authorizeAPI.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if let querys = authorizeAPI.querys {
            let queryItems = querys.map { name, value in
                URLQueryItem(name: name, value: value)
            }
            urlComponents.queryItems = queryItems
        }
        
        self.loginUrl = urlComponents.url!
        self.codeVerifier = codeVerifier
    }
}

/// Nintendo account login
extension LoginViewModel {
    
    func loginFlow(sessionTokenCode: String) {
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
                NotificationCenter.default.post(name: .loginedSuccessed, object: nil)
            }
            .store(in: &cancelBag)
    }
}
