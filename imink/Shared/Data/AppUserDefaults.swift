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
import WebKit

class AppUserDefaults: ObservableObject {
    static let shared = AppUserDefaults()
    
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
    
    @AppStorage("firstLaunch", store: UserDefaults.appGroup)
    var firstLaunch: Bool = true
    
    @AppStorage("sp2PrincipalId", store: UserDefaults.appGroup)
    var sp2PrincipalId: String?
    
    @StandardStorage(key: "sessionToken", store: UserDefaults.appGroup)
    var sessionToken: String? {
        didSet {
            if (oldValue != nil || naUser != nil), sessionToken == nil {
                NotificationCenter.default.post(
                    name: .logout,
                    object: nil
                )
                
                AppUserDefaults.shared.naUser = nil
                AppUserDefaults.shared.sp2PrincipalId = nil
                
                let cookieStorage = HTTPCookieStorage.shared
                for cookie in cookieStorage.cookies ?? [] {
                    cookieStorage.deleteCookie(cookie)
                }
            }
            
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    @StandardStorage(key: "naUser", store: UserDefaults.appGroup)
    var naUser: NAUser?
}
