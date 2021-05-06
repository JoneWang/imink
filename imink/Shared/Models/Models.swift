//
//  Battle.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import SplatNet2

typealias ActiveFestivals = SplatNet2.ActiveFestivals
typealias Battle = SplatNet2.Battle
typealias BattleOverview = SplatNet2.BattleOverview
typealias GameRule = SplatNet2.GameRule
typealias GameMode = SplatNet2.GameMode
typealias Udemae = SplatNet2.Udemae
typealias NicknameAndIcon = SplatNet2.NicknameAndIcon
public typealias Player = SplatNet2.Player
typealias Records = SplatNet2.Records
typealias SalmonRunSchedules = SplatNet2.SalmonRunSchedules
typealias Schedules = SplatNet2.Schedules
typealias Stage = SplatNet2.Stage
typealias TeamMember = SplatNet2.TeamMember
typealias TeamResult = SplatNet2.TeamResult
typealias JobOverview = SplatNet2.JobOverview
typealias Job = SplatNet2.Job
typealias Weapon = SplatNet2.Weapon

extension SalmonRunSchedules.Schedule.Weapon: Identifiable { }

extension Battle {
    
    var battleType: Battle.BattleType {
        switch self.gameMode.key {
        case .regular:
            return .regular
        case .gachi:
            return .gachi
        case .leaguePair, .leagueTeam:
            return .league
        case .fesSolo, .fesTeam:
            return .fes
        case .private:
            return .private
        }
    }
    
}

extension Battle.BattleType {
    
    var imageName: String {
        switch self {
        case .regular:
            return "RegularBattle"
        case .gachi:
            return "RankedBattle"
        case .league:
            return "LeagueBattle"
        case .fes:
            return "SplatfestBattle"
        case .private:
            return "PrivateBattle"
        }
    }
    
    var color: Color {
        switch self {
        case .regular:
            return AppColor.spLightGreen
        case .gachi:
            return AppColor.spOrange
        case .league:
            return AppColor.spPink
        case .fes:
            return AppColor.spYellow
        case .private:
            return AppColor.spPurple
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
