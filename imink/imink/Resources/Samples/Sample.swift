//
//  Sample.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

struct Sample {
    static func results() -> SP2BattleOverview {
        Sample.load("results.json", decodable: SP2BattleOverview.self)
    }
    
    static func battle() -> SP2Battle {
        Sample.load("result.json", decodable: SP2Battle.self)
    }
    
    private static func load<T>(_ filename: String, decodable: T.Type) -> T where T: Decodable {
        let data = try! Data(
            contentsOf: Bundle.main.url(forResource: filename, withExtension: nil)!
        )
        return data.decode(decodable)!
    }
}
