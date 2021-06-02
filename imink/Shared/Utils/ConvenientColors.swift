//
//  ConvenientColors.swift
//  imink
//
//  Created by Jone Wang on 2020/12/25.
//

import UIKit
import SwiftUI

extension Color {
    #if os(iOS)
    
    static var systemGray: Color {
        Color(.systemGray)
    }
    
    static var systemGray2: Color {
        Color(.systemGray2)
    }
    
    static var systemGray3: Color {
        Color(.systemGray3)
    }
    
    static var systemGray5: Color {
        Color(.systemGray5)
    }
    
    static var systemGray6: Color {
        Color(.systemGray6)
    }
    
    static var secondaryLabel: Color {
        Color(.secondaryLabel)
    }
    
    static var systemBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    static var secondarySystemBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var separator: Color {
        Color(.separator)
    }
    
    static var opaqueSeparator: Color {
        Color(.opaqueSeparator)
    }
    
    static var quaternarySystemFill: Color {
        Color(.quaternarySystemFill)
    }
    
    static var tertiaryLabel: Color {
        Color(.tertiaryLabel)
    }

    #endif
}
