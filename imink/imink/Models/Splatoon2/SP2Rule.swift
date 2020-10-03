//
//  SP2Rule.swift
//  imink
//
//  Created by 王强 on 2020/10/2.
//

import Foundation

struct SP2Rule: Codable {
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
