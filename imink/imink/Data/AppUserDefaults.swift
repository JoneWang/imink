//
//  Config.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import Foundation
import Combine
import SwiftUI

class AppUserDefaults: ObservableObject {
    static let shared = AppUserDefaults()
    
    @AppStorage("client_token", store: UserDefaults.appGroup)
    var clientToken: String?

    @StandardStorage(key: "user", store: UserDefaults.appGroup)
    var user: User? {
        didSet {
            if oldValue != nil, user == nil {
                NotificationCenter.default.post(
                    name: .logout,
                    object: nil
                )
            }
        }
    }
    
    @StandardStorage(key: "last_battle", store: UserDefaults.appGroup)
    var lastBattle: SP2Battle?
    
    @AppStorage("splatoon2_records", store: UserDefaults.appGroup)
    var splatoon2RecordsData: Data?
    
    @AppStorage("splatoon2_nickname_and_icon", store: UserDefaults.appGroup)
    var splatoon2NicknameAndIconData: Data?
}

@objc extension UserDefaults {
    
    private static let migrator = UserDefaultsMigrator(
        from: .standard,
        to: UserDefaults(suiteName: "group.wang.jone.imink") ?? .standard)
    
    @objc static let appGroup: UserDefaults = {
        migrator.migrate()
        return migrator.defaults()
    }()
    
}
