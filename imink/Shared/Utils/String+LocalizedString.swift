//
//  String+LocalizedString.swift
//  imink
//
//  Created by Jone Wang on 2020/10/27.
//

import Foundation
import SwiftUI

extension String {
    
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
}
