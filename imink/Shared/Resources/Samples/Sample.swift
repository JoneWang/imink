//
//  Sample.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

struct Sample {
    static func battle() -> SP2Battle {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let battle = try! decoder.decode(
            SP2Battle.self, from: try! Data(
                contentsOf: Bundle.main.url(
                    forResource: "result.json",
                    withExtension: nil
                )!
            )
        )
        
        return battle
    }
}
