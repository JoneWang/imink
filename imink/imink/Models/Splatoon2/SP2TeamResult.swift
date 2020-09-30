//
//  SP2TeamResult.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import Foundation

struct SP2TeamResult: Codable {
    let key: Key
    let name: String
    
    enum Key: String, Codable {
        case victory
        case defeat
    }
}
