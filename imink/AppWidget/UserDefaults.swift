//
//  UserDefaultsMigrator.swift
//  imink
//
//  Created by Jone Wang on 2020/10/17.
//

import Foundation

extension UserDefaults {
    
    static let appGroup: UserDefaults = {
        return UserDefaults(suiteName: "group.wang.jone.imink")!
    }()
    
}
