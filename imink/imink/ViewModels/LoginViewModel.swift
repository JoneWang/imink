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

struct LoginProgress {
    enum API: String {
        case nso
        case splatoon
        case imink
        
        var name: String {
            switch self {
            case .nso:
                return "NSO"
            case .splatoon:
                return "SplatNet"
            case .imink:
                return "imink"
            }
        }
        
        var color: Color {
            switch self {
            case .nso:
                return AppColor.nintendoRedColor
            case .imink:
                return AppColor.spPink
            case .splatoon:
                return AppColor.spLightGreen
            }
        }
    }
    
    let api: API
    let path: String
    var status: ProgressStatus
    
    init(api: API, path: String, status: ProgressStatus) {
        self.api = api
        self.path = path
        self.status = status
    }
    
    init(targetType: APITargetType, status: ProgressStatus) {
        if targetType is NSOAPI {
            self.api = .nso
        } else if targetType is Splatoon2API {
            self.api = .splatoon
        } else {
            self.api = .imink
        }
        
        self.path = targetType.path
        self.status = status
    }
}

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
    @Published var loginProgress: [LoginProgress] = []
    
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
        
        // Get latest nso version
        self.updateConfig()
    }
    
    func updateConfig() {
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
}

/// Nintendo account login
extension LoginViewModel {
    
    func loginFlow(sessionTokenCode: String) {
        status = .loading
        let nsoHelper = NSOAuthorization()
        
        $loginProgress.sink { list in
            print(list.count)
        }
        .store(in: &cancelBag)
        
        nsoHelper.currentStatus
            .map { [weak self] (targetType, status) -> [LoginProgress] in
                print("type: \(targetType.path), status: \(status)")
                
                guard var statusList = self?.loginProgress else { return [] }
                if var last = statusList.last, last.path == targetType.path {
                    last.status = status
                    statusList[statusList.count - 1] = last
                } else {
                    let progress = LoginProgress(targetType: targetType, status: status)
                    statusList.append(progress)
                }
                
                return statusList
            }
            .assign(to: \.loginProgress, on: self)
            .store(in: &cancelBag)
        
        nsoHelper.logIn(codeVerifier: codeVerifier, sessionTokenCode: sessionTokenCode)
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
