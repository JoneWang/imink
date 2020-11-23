//
//  Sample.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

struct Sample {
    static func results() -> BattleOverview {
        Sample.load("results.json", decodable: BattleOverview.self)
    }
    
    static func battle() -> Battle {
        Sample.load("result.json", decodable: Battle.self)
    }
    
    private static func load<T>(_ filename: String, decodable: T.Type) -> T where T: Decodable {
        let data = try! Data(
            contentsOf: Bundle.main.url(forResource: filename, withExtension: nil)!
        )
        return data.decode(decodable)!
    }
}
