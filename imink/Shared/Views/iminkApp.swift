//
//  imink_swiftuiApp.swift
//  Shared
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI
import URLImage

@main
struct iminkApp: App {
    init() {
        _ = try! AppDatabase()
        
        URLImageService.shared.setDefaultExpiryTime(3600.0 * 365)
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 600, minHeight: 400)
                .environmentObject(AppUserDefaults.shared)
        }
        .commands {
            SidebarCommands()
            ToolbarCommands()
        }
    }
}
