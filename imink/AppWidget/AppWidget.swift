//
//  AppWidget.swift
//  AppWidget
//
//  Created by Jone Wang on 2020/10/17.
//

import WidgetKit
import SwiftUI

@main
struct SwiftWidgetsBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        BattleScheduleWidget(
            gameMode: .regular,
            displayName: "Regular Battle",
            description: "widget_regular_schedule_preview_description"
        )
        BattleScheduleWidget(
            gameMode: .gachi,
            displayName: "Ranked Battle",
            description: "widget_ranked_schedule_preview_description"
        )
        BattleScheduleWidget(
            gameMode: .league,
            displayName: "League Battle",
            description: "widget_league_schedule_preview_description"
        )
    }
}
