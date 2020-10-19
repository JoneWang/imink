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
    var kind: WidgetKind = .regular
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(kind: WidgetKind) {
        self.kind = kind
    }
    
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(date: Date(), schedule: nil, nextSchedule: nil, size: .with(context.displaySize))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        updateSchedule { schedules in
            let entry = ScheduleEntry(
                date: Date(),
                schedule: schedules.first,
                nextSchedule: schedules[1],
                size: .with(context.displaySize))
            completion(entry)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
            let entry = ScheduleEntry(
                date: refreshDate,
                schedule: nil,
                nextSchedule: nil,
                size: .with(context.displaySize))
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ScheduleEntry] = []
        
        updateSchedule(mustLoading: true) { schedules in
            if schedules.count < 2 { return }
            
            for (i, schedule) in schedules.enumerated() {
                if schedules.count - 2 < i { continue }
                
                let entry = ScheduleEntry(date: i == 0 ? Date() : schedule.startDate, schedule: schedule, nextSchedule: schedules[i + 1], size: .with(context.displaySize))
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .after(schedules[schedules.count - 2].startDate))
            completion(timeline)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            let timeline = Timeline(entries: [ScheduleEntry(date: refreshDate, schedule: nil, nextSchedule: nil, size: .with(context.displaySize))], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

extension BattleScheduleProvider {
    
    func updateSchedule(
        mustLoading: Bool = false,
        success: @escaping ([SP2Schedule]) -> Void,
        failure: @escaping () -> Void
    ) {
        if let data = AppUserDefaults.shared.splatoon2BattleScheduleData,
           let schedules = data.decode(SP2Schedules.self) {
            let schedules = schedules.getSchedules(kind)
            
            if schedules.count > 2 {
                let lastSchedule = schedules[schedules.count - 2]
                if lastSchedule.startDate < Date() {
                    success(schedules)
                    if !mustLoading { return }
                }
            }
        }
        
        Splatoon2API.schedules
            .request()
            .compactMap { data -> SP2Schedules? in
                // Cache
                AppUserDefaults.shared.splatoon2BattleScheduleData = data
                return data.decode(SP2Schedules.self)
            }
            .receive(on: DispatchQueue.main)
            .map { $0.getSchedules(self.kind) }
            .sink(receiveCompletion: { result in
                if case .failure(_) = result {
                    failure()
                }
            }, receiveValue: { schedules in
                success(schedules)
            })
            .store(in: &cancelBag)
    }
    
}

extension SP2Schedules {
    
    func getSchedules(_ kind: WidgetKind) -> [SP2Schedule] {
        if kind == WidgetKind.regular {
            return self.regular
        } else if kind == WidgetKind.gachi {
            return self.gachi
        } else if kind == WidgetKind.league {
            return self.league
        }
        
        return self.regular
    }
    
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let schedule: SP2Schedule?
    let nextSchedule: SP2Schedule?
    let size: WidgetSize
    
}

enum WidgetSize {
    case size414x896
    case size375x812
    case size414x736
    case size375x667
    case size320x568
}


extension WidgetSize {
    
    static func with(_ size: CGSize) -> WidgetSize {
        if size.width == 414 {
            if size.height == 896 {
                return .size414x896
            } else if size.height == 736 {
                return .size414x736
            } else {
                return .size414x736
            }
        } else if size.width == 375 {
            if size.height == 812 {
                return .size375x812
            } else if size.height == 667 {
                return .size375x667
            } else {
                return .size375x812
            }
        } else if size.width == 320 {
            return .size320x568
        } else {
            return .size414x736
        }
    }
    
}

struct BattleScheduleWidgetEntryView : View {
    var entry: BattleScheduleProvider.Entry
    var kind: WidgetKind
    @Environment(\.widgetFamily) var family
    
    var ruleNameColor: Color {
        var color = Color("RegularScheduleRuleColor")
        switch kind {
        case .gachi:
            color = Color("RankedScheduleRuleColor")
        case .league:
            color = Color("LeagueScheduleRuleColor")
        case .regular:
            color = Color("RegularScheduleRuleColor")
        }
        return color
    }
    
    var vSpacing: CGFloat {
        var vSpacing: CGFloat = 11
        if entry.size == .size414x896 {
            vSpacing = 13
        } else if entry.size == .size375x667 {
            vSpacing = 8.5
        } else if entry.size == .size320x568 {
            vSpacing = 9
        }
        return vSpacing
    }
    
    var titleAndStageSpacing: CGFloat {
        var titleAndStageSpacing: CGFloat = 8
        if entry.size == .size414x896 {
            titleAndStageSpacing = 9
        }
        return titleAndStageSpacing
    }
    
    var backgroundName: String {
        switch kind {
        case .regular:
            return "RegularBattleBackground"
        case .gachi:
            return "RankedBattleBackground"
        case .league:
            return "LeagueBattleBackground"
        }
    }
    
    var body: some View {
        if entry.schedule != nil {
            makeContent()
                .background(
                    Image(backgroundName)
                        .aspectRatio(1, contentMode: .fill)
                )
                .padding(16)
        } else {
            makeContent()
                .redacted(reason: .placeholder)
                .background(
                    Image(backgroundName)
                        .aspectRatio(1, contentMode: .fill)
                )
                .padding(16)
        }
    }
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func makeContent() -> some View {
        VStack(spacing: vSpacing) {
            if family == .systemMedium {
                HStack(spacing: 10) {
                    VStack(spacing: titleAndStageSpacing) {
                        HStack {
                            Text("Now")
                                .sp1Font(size: 14)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                .unredacted()
                            
                            Spacer()
                        }
                        
                        makeStageImage(
                            stageId: entry.schedule?.stageA.id ?? "0",
                            stageName: entry.schedule?.stageA.name ?? "            "
                        )
                    }
                    
                    VStack(spacing: titleAndStageSpacing) {
                        HStack {
                            Spacer()
                            
                            Text("\(entry.schedule?.rule.name ?? "      ")")
                                .sp1Font(size: 14, color: ruleNameColor)
                                .shadow(color: Color.black.opacity(0.2), radius: 0, x: 1, y: 1)
                        }
                        
                        makeStageImage(
                            stageId: entry.schedule?.stageB.id ?? "0",
                            stageName: entry.schedule?.stageB.name ?? "            "
                        )
                    }
                }
                
                GeometryReader { geo in
                    Path { path in
                        path.move(to: .init(x: 0, y: 0))
                        path.addLine(to: .init(x: geo.size.width, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
                    .foregroundColor(Color.white.opacity(0.5))
                }
                .frame(height: 1)
                
                HStack(spacing: 10) {
                    VStack(spacing: titleAndStageSpacing) {
                        HStack {
                            Text("Next")
                                .sp1Font(size: 14)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                .unredacted()
                            
                            Spacer()
                        }
                        
                        makeStageImage(
                            stageId: entry.nextSchedule?.stageA.id ?? "0",
                            stageName: entry.nextSchedule?.stageA.name ?? "            "
                        )
                    }
                    
                    VStack(spacing: titleAndStageSpacing) {
                        HStack {
                            Spacer()
                            
                            Text("\(entry.nextSchedule?.rule.name ?? "      ")")
                                .sp1Font(size: 14, color: ruleNameColor)
                                .shadow(color: Color.black.opacity(0.2), radius: 0, x: 1, y: 1)
                        }
                        
                        makeStageImage(
                            stageId: entry.nextSchedule?.stageB.id ?? "0",
                            stageName: entry.nextSchedule?.stageB.name ?? "            "
                        )
                    }
                }
            } else {
                HStack { Text("Loading...") }
            }
        }
    }
    
    func makeStageImage(stageId: String, stageName: String) -> some View {
        var borderColor = Color("RegularScheduleStageBorderColor")
        switch kind {
        case .gachi:
            borderColor = Color("RankedScheduleStageBorderColor")
        case .league:
            borderColor = Color("LeagueScheduleStageBorderColor")
        case .regular:
            borderColor = Color("RegularScheduleStageBorderColor")
        }
        
        return Image("stage-\(stageId)")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minHeight: 0, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.black.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )
                    .opacity(0.4)
            )
            .overlay(Text("\(stageName)").sp2Font(), alignment: .center)
            .cornerRadius(6)
            .clipped()
    }
}

enum WidgetKind: String {
    case regular
    case gachi
    case league
}

struct BattleScheduleWidget: Widget {
    var kind: WidgetKind = .regular
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind.rawValue, provider: BattleScheduleProvider(kind: kind)) { entry in
            BattleScheduleWidgetEntryView(entry: entry, kind: kind)
        }
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("Salmon Run Schedule")
        .description("See the current schedule for Salmon Run.")
    }
}
