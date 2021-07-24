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
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        let content = VStack {
            if widgetFamily == .systemMedium {
                BattleScheduleMediumWidgetEntryView(entry: entry, gameMode: gameMode)
            }
            else if widgetFamily == .systemLarge {
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

extension BattleScheduleWidgetGameMode {
    var background: some View {
        switch self {
        case .regular:
            return WidgetBackgroundView(texture: .regularStreak)
        case .gachi:
            return WidgetBackgroundView(texture: .rankStreak)
        case .league:
            return WidgetBackgroundView(texture: .leagueStreak)
        }
    }
    
    var stageBorderColor: Color {
        switch self {
        case .regular:
            return Color("RegularScheduleStageBorderColor")
        case .gachi:
            return Color("RankedScheduleStageBorderColor")
        case .league:
            return Color("LeagueScheduleStageBorderColor")
        }
    }
}

struct BattleScheduleWidget: Widget {
    var gameMode: BattleScheduleWidgetGameMode = .regular
    var displayName: LocalizedStringKey = ""
    var description: LocalizedStringKey = ""
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: gameMode.rawValue, provider: BattleScheduleProvider(gameMode: gameMode)) { entry in
            GeometryReader() { geo in
                BattleScheduleWidgetEntryView(entry: entry, gameMode: gameMode)
                    .widgetSize(geo.size)
            }
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName(Text(displayName, tableName: splatNet2L10nTable))
        .description(description)
    }
}
