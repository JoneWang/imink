//
//  SP2Overview.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

struct SP2BattleOverview: Codable {
    let results: [Result]

    struct Result: Codable {
        let battleNumber: String
    }
}
