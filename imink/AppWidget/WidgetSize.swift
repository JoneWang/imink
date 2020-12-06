//
//  WidgetSize.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/10/21.
//

import Foundation
import SwiftUI
import WidgetKit

enum WidgetSize: Int {
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
        switch size.width {
        case 364:
            return .size364
        case 360:
            return .size360
        case 348:
            return .size348
        case 338:
            return .size338
        case 329:
            return .size329
        case 322:
            return .size322
        case 291:
            return .size291
        default:
            return .size348
        }
    }
    
    func cgSize(with widgetFamily: WidgetFamily) -> CGSize {
        let largeSizes = [
            CGSize(width: 364, height: 382),
            CGSize(width: 360, height: 376),
            CGSize(width: 348, height: 357),
            CGSize(width: 338, height: 354),
            CGSize(width: 329, height: 345),
            CGSize(width: 322, height: 324),
            CGSize(width: 291, height: 299),
        ]
        let mediumSizes = [
            CGSize(width: 364, height: 170),
            CGSize(width: 360, height: 169),
            CGSize(width: 348, height: 159),
            CGSize(width: 338, height: 158),
            CGSize(width: 329, height: 155),
            CGSize(width: 322, height: 148),
            CGSize(width: 291, height: 141),
        ]
        let smallSizes = [
            CGSize(width: 170, height: 170),
            CGSize(width: 169, height: 169),
            CGSize(width: 159, height: 159),
            CGSize(width: 158, height: 158),
            CGSize(width: 155, height: 155),
            CGSize(width: 148, height: 148),
            CGSize(width: 141, height: 141),
        ]
        switch widgetFamily {
        case .systemLarge:
            return largeSizes[self.rawValue]
        case .systemMedium:
            return mediumSizes[self.rawValue]
        case .systemSmall:
            return smallSizes[self.rawValue]
        }
    }
    
}
