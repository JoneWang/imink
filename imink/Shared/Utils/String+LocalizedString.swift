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
        let language = AppUserDefaults.shared.currentLanguage
        return NSLocalizedString(self, language: language)
    }
    
    func localized(with tableName: String) -> String {
        let language = AppUserDefaults.shared.currentLanguage
        return NSLocalizedString(self, language: language, tableName: tableName)
    }

}

func NSLocalizedString(_ key: String, language: String?, tableName: String? = nil) -> String {
    if let language = language {
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let bundle = Bundle(path: path!)
        let string = bundle?.localizedString(forKey: key, value: nil, table: tableName)
        return string ?? key
    } else {
        return NSLocalizedString(key, comment: "")
    }
}
