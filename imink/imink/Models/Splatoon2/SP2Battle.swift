//
//  SP2Battle.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

struct SP2Battle: Codable {
    let battleNumber: String
    let type: `Type`
    let stage: SP2Stage
    let gameMode: SP2GameMode
    let rule: SP2Rule
    let myTeamResult: SP2TeamResult
    let otherTeamResult: SP2TeamResult
    let myEstimateLeaguePoint: Int?
    let otherEstimateLeaguePoint: Int?
    let estimateGachiPower: Int?
    let myTeamPercentage: Double?
    let otherTeamPercentage: Double?
    let myTeamCount: Int?
    let otherTeamCount: Int?
    let playerResult: SP2TeamMember
    let myTeamMembers: [SP2TeamMember]?
    let otherTeamMembers: [SP2TeamMember]?

    enum `Type`: String, Codable {
        case regular
        case gachi
        case league
        case `private`
    }
}

extension SP2Stage {
    var imageURL: URL {
        Splatoon2API.host.appendingPathComponent(image)
    }
}

extension SP2Battle {
    var myPower: Int? {
        myEstimateLeaguePoint ?? estimateGachiPower
    }
    
    var otherPower: Int? {
        otherEstimateLeaguePoint
    }
    
    var myPoint: Double {
        if rule.key == .turfWar {
            return myTeamPercentage!
        } else {
            return Double(myTeamCount!)
        }
    }
    
    var otherPoint: Double {
        if rule.key == .turfWar {
            return otherTeamPercentage!
        } else {
            return Double(otherTeamCount!)
        }
    }
}
