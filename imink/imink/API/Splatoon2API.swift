//
//  Splatoon2API.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation

enum Splatoon2API {
    case battleInformation
    case result(battleNumber: String)
    case schedules
    case salmonRunSchedules
}

extension Splatoon2API: APITargetType {
    static let host = URL(string: "https://app.splatoon2.nintendo.net")!
    
    var baseURL: URL { Splatoon2API.host.appendingPathComponent("/api") }
    
    var path: String {
        switch self {
        case .battleInformation:
            return "/results"
        case .result(let battleNumber):
            return "/results/\(battleNumber)"
        case .schedules:
            return "/schedules"
        case .salmonRunSchedules:
            return "/coop_schedules"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .battleInformation, .result, .schedules, .salmonRunSchedules:
            return .get
        }
    }
    
    var headers: [String : String]? {
        if let user = AppUserDefaults.shared.user {
            return ["Cookie": "iksm_session=\(user.iksmSession)"]
        }

        return nil
    }
}
