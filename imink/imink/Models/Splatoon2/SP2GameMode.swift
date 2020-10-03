//
//  SP2GameMode.swift
//  imink
//
//  Created by 王强 on 2020/10/2.
//

import Foundation

struct SP2GameMode: Codable {
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
