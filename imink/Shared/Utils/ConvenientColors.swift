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
    
    static var secondarySystemBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var separator: Color {
        Color(.separator)
    }
    
    static var opaqueSeparator: Color {
        Color(.opaqueSeparator)
    }
    
    #endif
}
