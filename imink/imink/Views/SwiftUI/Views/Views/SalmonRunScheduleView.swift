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
            VStack(spacing: 10) {
                VStack {
                    Text("\(schedule.startTime, formatter: scheduleTimeFormat) - \(schedule.endTime, formatter: scheduleTimeFormat)")
                        .sp2Font(size: 15, color: Color.primary)
                        .colorInvert()
                }
                .padding(3)
                .padding(.horizontal)
                .background(Color.secondary)
                .clipShape(Capsule())
                
                if let stage = schedule.stage,
                   let weapons = schedule.weapons {
                    HStack(spacing: 16) {
                        VStack(spacing: 0) {
                            Text(stage.localizedName)
                                .sp2Font(color: AppColor.appLabelColor)
                                .padding(.bottom)
                            
                            ImageView.salomonRunStage(name: stage.imageName ?? "", imageURL: stage.image)
                                .aspectRatio(640.0 / 360.0, contentMode: .fill)
                                .clipped()
                                .continuousCornerRadius(8)
                        }
                        
                        VStack(spacing: 0) {
                            Text("Supplied Weapons")
                                .sp2Font(color: AppColor.appLabelColor)
                                .padding(.bottom)
                            
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    ForEach(weapons, id: \.id) { weapon in
                                        ImageView.weapon(id: weapon.id)
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(width: 35, height: 35)
                                    }
                                }
                                
                                Spacer()
                            }
                            
                            Spacer()
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
