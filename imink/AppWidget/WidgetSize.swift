//
//  WidgetSize.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/10/21.
//

import Foundation
import SwiftUI

enum WidgetSize {
    case size414x896
    case size375x812
    case size414x736
    case size375x667
    case size320x568
}

extension WidgetSize {
    
    static func with(_ size: CGSize) -> WidgetSize {
        if size.width == 414 {
            if size.height == 896 {
                return .size414x896
            } else if size.height == 736 {
                return .size414x736
            }
        } else if size.width == 375 {
            if size.height == 812 {
                return .size375x812
            } else if size.height == 667 {
                return .size375x667
            }
        } else if size.width == 320 {
            return .size320x568
        }
        
        return .size414x736
    }
    
}
