//
//  BattleScheduleWidget.swift
//  imink
//
//  Created by Jone Wang on 2020/10/17.
//

import Foundation
import WidgetKit
import SwiftUI
import Combine
import SDWebImage

class BattleScheduleProvider: TimelineProvider {
    private var cancelBag = Set<AnyCancellable>()

    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date(), schedule: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        let entry = ScheduleEntry(date: Date(), schedule: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ScheduleEntry] = []
        
        Splatoon2API.schedules
            .request()
            .decode(type: SP2Schedules.self)
            .receive(on: DispatchQueue.main)
            .map { $0.regular }
            .sink(receiveCompletion: { resule in
                if case .failure(_) = resule {
                    let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
                    let timeline = Timeline(entries: [ScheduleEntry(date: refreshDate, schedule: nil)], policy: .after(refreshDate))
                    completion(timeline)
                }
            }, receiveValue: { schedules in
                for schedule in schedules {
                    let entry = ScheduleEntry(date: schedule.endDate, schedule: schedule)
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            })
            .store(in: &cancelBag)
    }
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let schedule: SP2Schedule?
}

struct BattleScheduleWidgetEntryView : View {
    var entry: BattleScheduleProvider.Entry

    var body: some View {
        if let schedule = entry.schedule {
            HStack {
                VStack {
                    Text("Now")
                        .sp1Font(color: Color.primary)
                    
                    Image("stage-\(schedule.stageA.id)")
                        .resizable()
                        .frame(width: 140, height: 70)
                }
                VStack {
                    Text("Next")
                        .sp1Font(color: Color.primary)
                }
            }
        } else {
            Text("Loading...")
        }
    }
}

struct BattleScheduleWidget: Widget {
    let kind: String = "AppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BattleScheduleProvider()) { entry in
            BattleScheduleWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Salmon Run Schedule")
        .description("See the current schedule for Salmon Run.")
    }
}

//struct BattleScheduleWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        BattleScheduleWidget(entry: ScheduleEntry(date: Date(), schedule: nil))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}

struct NetworkImage: View {
    
    let url: URL?
    
    var body: some View {
        
        Group {
            if let url = url, let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            else {
                Image("placeholder-image")
            }
        }
    }
    
}
