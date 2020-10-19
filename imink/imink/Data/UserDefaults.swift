//
//  UserDefaults.swift
//  imink
//
//  Created by Jone Wang on 2020/10/17.
//

import Foundation
import SwiftUI
import WidgetKit

@objc extension UserDefaults {
    
    private static let migrator = UserDefaultsMigrator(
        from: .standard,
        to: UserDefaults(suiteName: "group.wang.jone.imink") ?? .standard)
    
    @objc static let appGroup: UserDefaults = {
        migrator.migrate()
        return migrator.defaults()
    }()
    
}
