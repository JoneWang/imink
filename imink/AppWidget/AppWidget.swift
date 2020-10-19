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
        BattleScheduleWidget(kind: .regular)
        BattleScheduleWidget(kind: .gachi)
        BattleScheduleWidget(kind: .league)
    }
}
