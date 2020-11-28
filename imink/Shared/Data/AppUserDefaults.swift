//
//  Config.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import Foundation
import Combine
import SwiftUI
import WidgetKit

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
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @StandardStorage(key: "last_battle", store: UserDefaults.appGroup)
    var lastBattle: Battle?
    
    @AppStorage("splatoon2_records", store: UserDefaults.appGroup)
    var splatoon2RecordsData: Data?
    
    @AppStorage("splatoon2_nickname_and_icon", store: UserDefaults.appGroup)
    var splatoon2NicknameAndIconData: Data?
    
    @AppStorage("splatoon2_battle_schedule", store: UserDefaults.appGroup)
    var splatoon2BattleScheduleData: Data?
    
    @AppStorage("splatoon2_salmon_run_schedule", store: UserDefaults.appGroup)
    var splatoon2SalmonRunScheduleData: Data?
    
    @AppStorage("currentLanguage", store: UserDefaults.appGroup)
    var currentLanguage: String?
}
