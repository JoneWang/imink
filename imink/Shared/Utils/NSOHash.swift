//
//  NSOHash.swift
//  imink
//
//  Created by Jone Wang on 2021/3/12.
//

import Foundation

struct NSOHash {
    
    static func urandom(length: Int) -> [UInt8] {
        var randomUInts = [UInt8]()
        for _ in 0..<length {
            randomUInts.append(UInt8.random(in: 0..<UInt8.max))
        }
        return randomUInts
    }
}

extension Sequence where Iterator.Element == UInt8 {
    
    var base64EncodedString: String {
        Data(self)
            .base64EncodedString()
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "+", with: "-")
    }
}
