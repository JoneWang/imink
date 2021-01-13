//
//  BattleScheduleProvider.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/10/21.
//

import Foundation
import WidgetKit
import Combine

enum BattleScheduleWidgetGameMode: String {
    case regular
    case gachi
    case league
}

struct ScheduleEntry: TimelineEntry {
    let date: Date
    let schedules: [Schedules.Schedule]?
    let size: WidgetSize
    let family: WidgetFamily
}

class BattleScheduleProvider: TimelineProvider {
    var gameMode: BattleScheduleWidgetGameMode = .regular
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(gameMode: BattleScheduleWidgetGameMode) {
        self.gameMode = gameMode
    }
    
    func placeholder(in context: Context) -> ScheduleEntry {
        ScheduleEntry(
            date: Date(),
            schedules: nil,
            size: .with(context.displaySize),
            family: context.family
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ScheduleEntry) -> ()) {
        updateSchedule { schedules in
            let entry = ScheduleEntry(
                date: Date(),
                schedules: schedules.count >= 3 ? [schedules[0], schedules[1], schedules[2]] : nil,
                size: .with(context.displaySize),
                family: context.family)
            completion(entry)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
            let entry = ScheduleEntry(
                date: refreshDate,
                schedules: nil,
                size: .with(context.displaySize),
                family: context.family)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ScheduleEntry>) -> ()) {
        var entries: [ScheduleEntry] = []
        
        updateSchedule(mustLoading: true) { schedules in
            if schedules.count < 2 { return }
            
            for (i, schedule) in schedules.enumerated() {
                if schedules.count - 3 < i { continue }
                
                let entry = ScheduleEntry(
                    date: i == 0 ? Date() : schedule.startTime,
                    schedules: Array(schedules[i..<i+3]),
                    size: .with(context.displaySize),
                    family: context.family
                )
                entries.append(entry)
            }
            
            let timeline = Timeline(entries: entries, policy: .after(schedules[schedules.count - 3].startTime))
            completion(timeline)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            let timeline = Timeline(
                entries: [ScheduleEntry(
                            date: refreshDate,
                            schedules: nil,
                            size: .with(context.displaySize),
                            family: context.family)],
                policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

extension BattleScheduleProvider {
    
    func updateSchedule(
        mustLoading: Bool = false,
        success: @escaping ([Schedules.Schedule]) -> Void,
        failure: @escaping () -> Void
    ) {
        if let data = AppUserDefaults.shared.splatoon2BattleScheduleData,
           let schedules = data.decode(Schedules.self) {
            let schedules = schedules.getSchedules(gameMode)
            
            if schedules.count > 2 {
                let lastSchedule = schedules[schedules.count - 2]
                if lastSchedule.startTime < Date() {
                    success(schedules)
                    if !mustLoading { return }
                }
            }
        }
        
        AppAPI.schedules
            .request()
            .compactMap { data -> Schedules? in
                // Cache
                AppUserDefaults.shared.splatoon2BattleScheduleData = data
                return data.decode(Schedules.self)
            }
            .receive(on: DispatchQueue.main)
            .map { $0.getSchedules(self.gameMode) }
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

extension Schedules {
    
    func getSchedules(_ kind: BattleScheduleWidgetGameMode) -> [Schedules.Schedule] {
        if kind == BattleScheduleWidgetGameMode.regular {
            return self.regular
        } else if kind == BattleScheduleWidgetGameMode.gachi {
            return self.gachi
        } else if kind == BattleScheduleWidgetGameMode.league {
            return self.league
        }
        
        return self.regular
    }
    
}
