//
//  Battle.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

//import SplatNet2

//typealias ActiveFestivals = SplatNet2.ActiveFestivals
//typealias Battle = SplatNet2.Battle
//typealias BattleOverview = SplatNet2.BattleOverview
//typealias GameMode = SplatNet2.GameMode
//typealias NicknameAndIcon = SplatNet2.NicknameAndIcon
//typealias Player = SplatNet2.Player
//typealias Records = SplatNet2.Records
//typealias SalmonRunSchedules = SplatNet2.SalmonRunSchedules
//typealias Schedules = SplatNet2.Schedules
//typealias Stage = SplatNet2.Stage
//typealias TeamMember = SplatNet2.TeamMember
//typealias TeamResult = SplatNet2.TeamResult

extension GameMode {
    
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

extension Schedules.Schedule.GameMode {
    
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

extension Battle {
    
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

import SwiftUI

extension SN2Color {
    var color: Color {
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
