//
//  String+LocalizedString.swift
//  imink
//
//  Created by Jone Wang on 2020/10/27.
//

import Foundation
import SwiftUI

let splatNet2L10nTable = "SplatNet2"

extension String {
    
    var localizedKey: LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
    var localized: String {
        let language = AppUserDefaults.shared.currentLanguage
        return NSLocalizedString(self, language: language)
    }

}

func NSLocalizedString(_ key: String, language: String?) -> String {
    if let language = language {
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let bundle = Bundle(path: path!)
        let string = bundle?.localizedString(forKey: key, value: nil, table: nil)
        return string ?? key
    } else {
        return NSLocalizedString(key, comment: "")
    }
}
