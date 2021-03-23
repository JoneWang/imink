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
}

extension AppAPI: APITargetType {
    var baseURL: URL { URL(string: "https://api.imink.jone.wang")! }
    
    var path: String {
        switch self {
        case .schedules:
            return "/schedules"
        case .salmonRunSchedules:
            return "/salmonrun_schedules"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .schedules,
             .salmonRunSchedules:
            return .get
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var querys: [(String, String?)]? {
        return nil
    }
    
    var data: MediaType? {
        return nil
    }
}
