//
//  WidgetSize.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/10/21.
//

import Foundation
import SwiftUI

enum WidgetSize {
    case size364 // iPhone 12 Pro Max
    case size360 // iPhone 11 Pro Max
    case size348 // iPhone 8 Plus
    case size338 // iPhone 12 Pro
    case size329 // iPhone 11 Pro
    case size322 // iPhone 8
    case size291 // iPhone SE 1st-gen
}

extension WidgetSize {
    
    static func with(_ size: CGSize) -> WidgetSize {
        if size.width == 360 {
            return .size360
        } else if size.width == 348 {
            return .size348
        } else if size.width == 338 {
            return .size338
        } else if size.width == 329 {
            return .size329
        } else if size.width == 322 {
            return .size322
        } else if size.width == 291 {
            return .size291
        }
        
        return .size348
    }
    
}
