//
//  SalmonRunScheduleWidget.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/6.
//

import Foundation
import WidgetKit
import SwiftUI

struct SalmonRunScheduleWidgetEntryView : View {
    var entry: SalmonRunScheduleProvider.Entry
    
    @Environment(\.widgetFamily) var widgetFamily
    
    var body: some View {
        let content = VStack {
            if widgetFamily == .systemMedium {
                SalmonRunScheduleMediumWidgetEntryView(entry: entry)
            }
            else if widgetFamily == .systemLarge {
                SalmonRunScheduleLargeWidgetEntryView(entry: entry)
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

struct SalmonRunScheduleWidget: Widget {
    var displayName: LocalizedStringKey = ""
    var description: LocalizedStringKey = ""
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "SalmonRun", provider: SalmonRunScheduleProvider()) { entry in
            GeometryReader() { geo in
                SalmonRunScheduleWidgetEntryView(entry: entry)
                    .widgetSize(geo.size)
            }
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName(displayName)
        .description(description)
    }
}
