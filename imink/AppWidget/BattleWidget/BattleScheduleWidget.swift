//
//  BattleScheduleWidget.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/10/21.
//

import Foundation
import WidgetKit
import SwiftUI

struct BattleScheduleWidgetEntryView : View {
    var entry: BattleScheduleProvider.Entry
    var gameMode: BattleScheduleWidgetGameMode
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let content = VStack {
            if family == .systemMedium {
                BattleScheduleMediumWidgetEntryView(entry: entry, gameMode: gameMode)
            }
            else if family == .systemLarge {
                BattleScheduleLargeWidgetEntryView(entry: entry, gameMode: gameMode)
            }
        }

        return Group {
            if let code = AppUserDefaults.shared.currentLanguage {
                content
                    .environment(\.locale, Locale(identifier: code))
            } else {
                content
            }
        }
    }
}

struct BattleScheduleWidget: Widget {
    var gameMode: BattleScheduleWidgetGameMode = .regular
    var displayName: LocalizedStringKey = ""
    var description: LocalizedStringKey = ""
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: gameMode.rawValue, provider: BattleScheduleProvider(gameMode: gameMode)) { entry in
            BattleScheduleWidgetEntryView(entry: entry, gameMode: gameMode)
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName(Text(displayName, tableName: splatNet2L10nTable))
        .description(description)
    }
}
