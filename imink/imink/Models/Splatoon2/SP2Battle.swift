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
    let stage: Stage
    let gameMode: GameMode
    let rule: Rule
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
    
    struct Stage: Codable {
        let id: String
        let name: String
        let image: String
    }
    
    struct GameMode: Codable {
        let key: Key
        let name: String
        
        enum Key: String, Codable {
            case regular
            case leaguePair = "league_pair"
            case leagueTeam = "league_team"
            case gachi
            case fesTeam = "fes_team"
            case fesSolo = "fes_solo"
            case `private`
        }
    }
    
    struct Rule: Codable {
        let key: Key
        let name: String
        let multilineName: String
        
        enum Key: String, Codable {
            case turfWar = "turf_war"
            case splatZones = "splat_zones"
            case towerControl = "tower_control"
            case rainmaker
            case clamBlitz = "clam_blitz"
        }
    }
}

extension SP2Battle.Stage {
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
