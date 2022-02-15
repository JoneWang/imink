//
//  SalmonRunScheduleProvider.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/6.
//

import Foundation
import WidgetKit
import Combine

struct SalmonRunScheduleEntry: TimelineEntry {
    let date: Date
    let schedules: [SalmonRunSchedules.Schedule]?
}

class SalmonRunScheduleProvider: TimelineProvider {
    
    private var cancelBag = Set<AnyCancellable>()
    
    func placeholder(in context: Context) -> SalmonRunScheduleEntry {
        SalmonRunScheduleEntry(
            date: Date(),
            schedules: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SalmonRunScheduleEntry) -> ()) {
        updateSchedule { schedules in
            let entry = SalmonRunScheduleEntry(
                date: Date(),
                schedules: schedules)
            completion(entry)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
            let entry = SalmonRunScheduleEntry(
                date: refreshDate,
                schedules: nil)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SalmonRunScheduleEntry>) -> ()) {
        updateSchedule(mustLoading: true) { schedules in
            if schedules.count < 4 { return }
                        
            var entries: [SalmonRunScheduleEntry] = []
            
            for i in 0..<schedules.count {
                if schedules.count - 5 < i { continue }

                let showSchedules = Array(schedules[i..<i+5])

                let startTime = showSchedules.first!.startTime
                print("start: \(startTime)")
                let endTime = showSchedules.first!.endTime
                let hours = Calendar.current.dateComponents([.hour], from: startTime, to: endTime).hour!
                for j in 0..<hours {
                    let refreshTime = Calendar.current.date(byAdding: .hour, value: j, to: startTime)!
                    
                    if refreshTime < Date() { continue }
                    print(refreshTime)

                    let entry = SalmonRunScheduleEntry(
                        date: refreshTime,
                        schedules: showSchedules
                    )
                    entries.append(entry)
                }
            }
            
            // entries not too long
            entries = Array(entries[0..<48])
            
            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            let timeline = Timeline(
                entries: [SalmonRunScheduleEntry(
                            date: refreshDate,
                            schedules: nil)],
                policy: .atEnd)
            completion(timeline)
        }
    }
}

extension SalmonRunScheduleProvider {
    
    func updateSchedule(
        mustLoading: Bool = false,
        success: @escaping ([SalmonRunSchedules.Schedule]) -> Void,
        failure: @escaping () -> Void
    ) {
        // Reduce the frequency of iksm_session expiration
        IksmSessionManager.shared.activateIksmSession()
        
        AppAPI.salmonRunSchedules()
            .request()
            .decode(type: SalmonRunSchedules.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                if case .failure(_) = result {
                    failure()
                }
            }, receiveValue: { schedules in
                success(schedules.details)
            })
            .store(in: &cancelBag)
    }
    
}
