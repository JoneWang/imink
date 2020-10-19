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
            kind: .regular,
            displayName: "widget_regular_schedule_preview_title",
            description: "widget_regular_schedule_preview_description"
        )
        BattleScheduleWidget(
            kind: .gachi,
            displayName: "widget_ranked_schedule_preview_title",
            description: "widget_ranked_schedule_preview_description"
        )
        BattleScheduleWidget(
            kind: .league,
            displayName: "widget_league_schedule_preview_title",
            description: "widget_league_schedule_preview_description"
        )
    }
}
