//
//  StringInterpolation.swift
//  imink
//
//  Created by Jone Wang on 2020/9/7.
//

import Foundation
import SwiftUI

extension LocalizedStringKey.StringInterpolation {
    mutating func appendInterpolation(_ value: Int, usesGroupingSeparator: Bool = false) {
        if let result = Formatters.int(value, usesGroupingSeparator: usesGroupingSeparator)
            .string(from: value as NSNumber) {
            appendLiteral(result)
        }
    }
    
    mutating func appendInterpolation(_ value: Double, places: Int = 1, usesGroupingSeparator: Bool = false) {
        if let result = Formatters.double(value, places: places, usesGroupingSeparator: usesGroupingSeparator)
            .string(from: value as NSNumber) {
            appendLiteral(result)
        }
    }
}

extension String.StringInterpolation {
    mutating func appendInterpolation(_ value: Int, usesGroupingSeparator: Bool = false) {
        if let result = Formatters.int(value, usesGroupingSeparator: usesGroupingSeparator)
            .string(from: value as NSNumber) {
            appendLiteral(result)
        }
    }
    
    mutating func appendInterpolation(_ value: Double, places: Int = 1, usesGroupingSeparator: Bool = false) {
        if let result = Formatters.double(value, places: places, usesGroupingSeparator: usesGroupingSeparator)
            .string(from: value as NSNumber) {
            appendLiteral(result)
        }
    }
}

struct Formatters {
    static func int(_ value: Int, usesGroupingSeparator: Bool = false) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = usesGroupingSeparator
        return formatter
    }
    
    static func double(_ value: Double, places: Int = 1, usesGroupingSeparator: Bool = false) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = usesGroupingSeparator
        
        // Remove .0
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = places
        }
        
        return formatter
    }
}
