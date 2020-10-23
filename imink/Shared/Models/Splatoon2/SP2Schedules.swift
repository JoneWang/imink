//
//  SP2Schedules.swift
//  imink
//
//  Created by 王强 on 2020/10/2.
//

import Foundation

struct SP2Schedules: Codable {
    let regular: [SP2Schedule]
    let gachi: [SP2Schedule]
    let league: [SP2Schedule]
}

struct SP2Schedule: Codable {
    let id: Int
    let stageA: SP2Stage
    let stageB: SP2Stage
    let gameMode: GameMode
    let startTime: TimeInterval
    let endTime: TimeInterval
    let rule: SP2Rule
    
    struct GameMode: Codable {
        let key: Key
        let name: String
        
        enum Key: String, Codable {
            case regular
            case gachi
            case league
        }
    }
}

extension SP2Schedule {
    
    var startDate: Date {
        Date(timeIntervalSince1970: startTime)
    }
    
    var endDate: Date {
        Date(timeIntervalSince1970: endTime)
    }
    
}

extension SP2Schedule.GameMode {
    
    var imageName: String {
        switch key {
        case .regular:
            return "RegularBattle"
        case .gachi:
            return "RankedBattle"
        case .league:
            return "LeagueBattle"
        }
    }
    
}
