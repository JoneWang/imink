//
//  AppAPI.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation

enum AppAPI {
    case schedules
    case salmonRunSchedules
    
    // If you want to use this api, please check the documentation
    // Docs: https://github.com/JoneWang/imink/wiki/imink-API-Document
    case f(naIdToken: String, requestId: String, timestamp: String, hashMethod: HashMethod)
    
    internal enum HashMethod: String {
        case hash1 = "1", hash2 = "2"
    }
}

extension AppAPI: APITargetType {
    var baseURL: URL { URL(string: "https://api.imink.jone.wang")! }
    
    var path: String {
        switch self {
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
        case .schedules,
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
        return nil
    }
    
    var data: MediaType? {
        switch self {
        case .f(let naIdToken, let requestId, let timestamp, let hashMethod):
            return .jsonData([
                "token": naIdToken,
                "timestamp": "\(timestamp)",
                "request_id": requestId,
                "hash_method": hashMethod.rawValue
            ])
        default:
            return nil
        }
    }
}
