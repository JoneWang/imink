//
//  imink_swiftuiApp.swift
//  Shared
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI

@main
struct iminkApp: App {
    init() {
        _ = try! AppDatabase()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .frame(minWidth: 600, minHeight: 400)
                .environmentObject(AppUserDefaults.shared)
        }
        .commands {
            // Hide new window menu
            CommandGroup(replacing: CommandGroupPlacement.newItem) { }
            
            SidebarCommands()
            ToolbarCommands()
        }
    }
}
