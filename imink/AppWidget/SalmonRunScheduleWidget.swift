//
//  SalmonRunScheduleWidget.swift
//  imink
//
//  Created by Jone Wang on 2020/10/17.
//

import Foundation
import SwiftUI
import WidgetKit

//struct SalmonRunScheduleProvider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), name: "Jone")
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), name: "Your name")
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, name: "\(AppUserDefaults.shared.user?.iksmSession) \(hourOffset)")
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct SalmonRunScheduleWidgetEntryView : View {
//    var entry: SalmonRunScheduleProvider.Entry
//
//    var body: some View {
//        Text(entry.name)
//    }
//}
//
//struct SalmonRunScheduleWidget: Widget {
//    let kind: String = "AppWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: SalmonRunScheduleProvider()) { entry in
//            SalmonRunScheduleWidgetEntryView(entry: entry)
//        }
//        .supportedFamilies([.systemMedium])
//        .configurationDisplayName("Salmon Run Schedule")
//        .description("See the current schedule for Salmon Run.")
//    }
//}

//struct SalmonRunScheduleWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        SalmonRunScheduleWidget(entry: SimpleEntry(date: Date(), name: "haha"))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
