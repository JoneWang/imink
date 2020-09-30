//
//  TeamMember.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import Foundation

struct SP2TeamMember: Codable {
    let killCount: Int
    let assistCount: Int
    let deathCount: Int
    let specialCount: Int
    let gamePaintPoint: Int
    let sortScore: Int
    let player: SP2Player
}
