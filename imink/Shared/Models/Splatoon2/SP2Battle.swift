//
//  SP2Battle.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import SplatNet2

typealias SP2Battle = SplatNet2.Battle

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
