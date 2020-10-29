//
//  AppAPI.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation

enum AppAPI {
    case loginURL
    case signIn(authCodeVerifier: String, loginInfo: String)
    case me(clientToken: String? = nil)
}

extension AppAPI: APITargetType {
    var baseURL: URL { URL(string: "https://api.imink.jone.wang")! }
    
    var path: String {
        switch self {
        case .loginURL:
            return "/account/login_url"
        case .signIn:
            return "/account/sign_in"
        case .me:
            return "/me"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .loginURL, .me:
            return .get
        case .signIn:
            return .post
        }
    }
    
    var headers: [String : String]? {
        if case let .me(clientToken) = self,
           let token = clientToken {
            return ["X-Client-Token": token]
        }
        
        if let clientToken = AppUserDefaults.shared.clientToken {
            return ["X-Client-Token": clientToken]
        }

        return nil
    }
    
    var querys: [(String, String?)]? {
        return nil
    }
    
    var data: MediaType? {
        switch self {
        case .signIn(let authCodeVerifier, let loginInfo):
            return .jsonData(
                [
                    "auth_code_verifier": authCodeVerifier,
                    "login_info": loginInfo
                ]
            )
        default:
            return nil
        }
    }
}
