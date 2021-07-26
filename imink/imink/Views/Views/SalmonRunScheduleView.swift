//
//  SalmonRunScheduleView.swift
//  imink
//
//  Created by Jone Wang on 2020/10/6.
//

import SwiftUI
import InkCore

struct SalmonRunScheduleView: View {
    let schedules: SalmonRunSchedules
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
    
    private var dataSource: [SalmonRunSchedules.Schedule] {
        schedules.details +
            schedules.schedules.filter { s in !schedules.details.contains { $0.$startTime == s.$startTime } }
    }
    
    var body: some View {
        ForEach(dataSource, id: \.startTime) { schedule in
            VStack {
                VStack {
                    Text("\(schedule.startTime, formatter: scheduleTimeFormat) - \(schedule.endTime, formatter: scheduleTimeFormat)")
                        .sp2Font(size: 15, color: Color.primary)
                        .colorInvert()
                }
                .padding(3)
                .padding(.horizontal)
                .background(Color.secondary)
                .clipShape(Capsule())
                .padding(.bottom, 5)

                if let stage = schedule.stage,
                   let weapons = schedule.weapons {
                    VStack(spacing: 12) {
                        HStack(spacing: 16) {
                            Text(stage.localizedName)
                                .sp2Font(color: AppColor.appLabelColor)
                                .frame(maxWidth: .infinity)
                            
                            Text("Supplied Weapons")
                                .sp2Font(color: AppColor.appLabelColor)
                                .frame(maxWidth: .infinity)
                        }
                        
                        HStack(spacing: 16) {
                            ImageView.salomonRunStage(name: stage.imageName ?? "", imageURL: stage.image)
                                .aspectRatio(640.0 / 360.0, contentMode: .fill)
                                .clipped()
                                .continuousCornerRadius(8)
                                .frame(maxWidth: .infinity)
                            
                            HStack(alignment: .center) {
                                ForEach(weapons, id: \.id) { weapon in
                                    ImageView.weapon(id: weapon.id)
                                        .aspectRatio(1, contentMode: .fit)
                                        .frame(maxWidth: .infinity)
                                        .frame(minHeight: 70)
                                        .minimumScaleFactor(0.3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(16)
            .background(AppColor.listItemBackgroundColor)
            .continuousCornerRadius(10)
        }
    }
}
