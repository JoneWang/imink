//
//  AppAPI.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation

enum AppAPI {
    case me(clientToken: String? = nil)
}

extension AppAPI: APITargetType {
    var baseURL: URL { URL(string: "https://api.imink.jone.wang")! }
    
    var path: String {
        switch self {
        case .me:
            return "/me"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .me:
            return .get
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
}
