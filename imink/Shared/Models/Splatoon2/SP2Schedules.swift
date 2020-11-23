//
//  SP2Schedules.swift
//  imink
//
//  Created by 王强 on 2020/10/2.
//

import SplatNet2

typealias SP2Schedules = SplatNet2.Schedules
typealias SP2Schedule = SplatNet2.Schedules.Schedule

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
