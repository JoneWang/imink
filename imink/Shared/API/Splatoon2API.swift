//
//  Splatoon2API.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation

enum Splatoon2API {
    case root(language: String, gameWebToken: String)
    case battleInformation
    case result(battleNumber: String)
    case schedules
    case salmonRunSchedules
    case records
    case nicknameAndIcon(id: String, iksmSession: String? = nil)
    case activeFestivals
    case jobOverview
    case job(id: Int)
}

extension Splatoon2API: APITargetType {
    
    static let host = URL(string: "https://app.splatoon2.nintendo.net")!
    
    var baseURL: URL { Splatoon2API.host.appendingPathComponent("/api") }
    
    var path: String {
        switch self {
        case .root:
            return "/"
        case .battleInformation:
            return "/results"
        case .result(let battleNumber):
            return "/results/\(battleNumber)"
        case .schedules:
            return "/schedules"
        case .salmonRunSchedules:
            return "/coop_schedules"
        case .records:
            return "/records"
        case .nicknameAndIcon:
            return "/nickname_and_icon"
        case .activeFestivals:
            return "/festivals/active"
        case .jobOverview:
            return "coop_results"
        case .job(let id):
            return "coop_results/\(id)"
        }
    }
    
    var method: APIMethod {
        switch self {
        case .battleInformation,
             .result,
             .schedules,
             .salmonRunSchedules,
             .records,
             .nicknameAndIcon,
             .activeFestivals,
             .jobOverview,
             .job,
             .root:
            return .get
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .root(_, let gameWebToken):
            return [
                "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
                "Accept-Language": "ja-jp",
                "x-gamewebtoken": gameWebToken,
                "x-isappanalyticsoptedin": "false",
                "x-isanalyticsoptedin": "false",
                "Accept-Encoding": "gzip, deflate, br"
            ]
        default:
            return nil
        }
    }
    
    var querys: [(String, String?)]? {
        switch self {
        case .root(let language, _):
            return [("lang", language)]
        case .nicknameAndIcon(let id, _):
            return [("id", id)]
        default:
            return nil
        }
    }
    
    var data: MediaType? {
        return nil
    }
}

extension Splatoon2API {
    
    static var sessionIsValid: Bool {
        
        let sessionCookie = HTTPCookieStorage.shared.cookies?
            .first(where: { $0.name == "iksm_session" })
        if let expiresDate = sessionCookie?.expiresDate {
            return expiresDate < Date()
        } else {
            return false
        }
    }
}
