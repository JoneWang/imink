//
//  AppAPI.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation

enum AppAPI {
    case config
    
    case schedules
    case salmonRunSchedules(page: Int = 1)
    
    case f(naIdToken: String, hashMethod: HashMethod)
    
    internal enum HashMethod: String {
        case hash1 = "1", hash2 = "2"
    }
}

// If you want to use this api, please check the documentation
// Docs: https://github.com/JoneWang/imink/wiki/imink-API-Documentation
extension AppAPI: APITargetType {
    var baseURL: URL { URL(string: "https://api.imink.jone.wang")! }
    
    var path: String {
        switch self {
        case .config:
            return "/config"
        case .schedules:
            return "/schedules"
        case .salmonRunSchedules:
            return "/salmonrun_schedules"
        case .f:
            return "/f"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .config,
             .schedules,
             .salmonRunSchedules:
            return .get
        case .f:
            return .post
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var querys: [(String, String?)]? {
        switch self {
        case .salmonRunSchedules(let page):
            return [("p", "\(page)")]
        default:
            return nil
        }
    }
    
    var data: MediaType? {
        switch self {
        case .f(let naIdToken, let hashMethod):
            return .jsonData([
                "token": naIdToken,
                "hash_method": hashMethod.rawValue
            ])
        default:
            return nil
        }
    }
}
