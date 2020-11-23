//
//  SP2GameMode.swift
//  imink
//
//  Created by 王强 on 2020/10/2.
//

import SplatNet2

typealias SP2GameMode = SplatNet2.GameMode

extension SP2GameMode {
    
    var imageName: String {
        switch key {
        case .regular:
            return "RegularBattle"
        case .gachi:
            return "RankedBattle"
        case .leaguePair:
            return "LeagueBattle"
        case .leagueTeam:
            return "LeagueBattle"
        case .fesTeam:
            return "SplatfestBattle"
        case .fesSolo:
            return "SplatfestBattle"
        case .private:
            return "PrivateBattle"
        }
    }
    
}
