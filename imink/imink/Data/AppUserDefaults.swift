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
    
    @AppStorage("client_token")
    var clientToken: String?

    @StandardStorage(key: "user")
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
    
    @StandardStorage(key: "last_battle")
    var lastBattle: SP2Battle?
}
