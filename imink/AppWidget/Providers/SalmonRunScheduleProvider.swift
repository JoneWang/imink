//
//  SalmonRunScheduleProvider.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/6.
//

import Foundation
import WidgetKit
import Combine
import CXMoya

struct SalmonRunScheduleEntry: TimelineEntry {
    let date: Date
    let schedules: SalmonRunSchedules?
    let size: WidgetSize
    let family: WidgetFamily
}

class SalmonRunScheduleProvider: TimelineProvider {
    
    private var cancelBag = Set<AnyCancellable>()
    
    func placeholder(in context: Context) -> SalmonRunScheduleEntry {
        SalmonRunScheduleEntry(
            date: Date(),
            schedules: nil,
            size: .with(context.displaySize),
            family: context.family
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SalmonRunScheduleEntry) -> ()) {
        updateSchedule { schedules in
            let entry = SalmonRunScheduleEntry(
                date: Date(),
                schedules: schedules,
                size: .with(context.displaySize),
                family: context.family)
            completion(entry)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .second, value: 10, to: Date())!
            let entry = SalmonRunScheduleEntry(
                date: refreshDate,
                schedules: nil,
                size: .with(context.displaySize),
                family: context.family)
            completion(entry)
        }
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SalmonRunScheduleEntry>) -> ()) {
        
        updateSchedule(mustLoading: true) { schedules in
            guard let firstSchedule = schedules.details.first else {
                return
            }
            
            let entry = SalmonRunScheduleEntry(
                date: firstSchedule.startTime,
                schedules: schedules,
                size: .with(context.displaySize),
                family: context.family
            )
            
            let timeline = Timeline(entries: [entry], policy: .after(firstSchedule.endTime))
            completion(timeline)
        } failure: {
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
            let timeline = Timeline(
                entries: [SalmonRunScheduleEntry(
                            date: refreshDate,
                            schedules: nil,
                            size: .with(context.displaySize),
                            family: context.family)],
                policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

extension SalmonRunScheduleProvider {
    
    func updateSchedule(
        mustLoading: Bool = false,
        success: @escaping (SalmonRunSchedules) -> Void,
        failure: @escaping () -> Void
    ) {
        if let data = AppUserDefaults.shared.splatoon2SalmonRunScheduleData,
           let schedules = data.decode(SalmonRunSchedules.self) {
            
            if let firstSchedule = schedules.details.first {
                if firstSchedule.endTime < Date() {
                    success(schedules)
                    if !mustLoading { return }
                }
            }
        }
        
        sn2Provider.requestPublisher(.salmonRunSchedules)
            .map(\.data)
            .compactMap { data -> SalmonRunSchedules? in
                // Cache
                AppUserDefaults.shared.splatoon2SalmonRunScheduleData = data
                return data.decode(SalmonRunSchedules.self)
            }
            .receive(on: DispatchQueue.main)
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
