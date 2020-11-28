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
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        let content = VStack {
            if family == .systemMedium {
                SalmonRunScheduleMediumWidgetEntryView(entry: entry)
            }
            else if family == .systemLarge {
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
            SalmonRunScheduleWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium, .systemLarge])
        .configurationDisplayName(displayName)
        .description(description)
    }
}
