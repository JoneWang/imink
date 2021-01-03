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
                    HStack(alignment: .top) {
                        
                        VStack(spacing: 0) {
                            
                            Text(stage.name.localizedKey)
                                .sp2Font(color: AppColor.appLabelColor)
                            
                            SalomonRunStageImageView(name: stage.name)
                                .aspectRatio(640 / 360, contentMode: .fill)
                                .frame(minWidth: 100)
                                .continuousCornerRadius(8)
                                .padding(.top)
                            
                        }
                        
                        VStack(spacing: 0) {
                            
                            Text("Supplied Weapons")
                                .sp2Font(color: AppColor.appLabelColor)
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    
                                    ForEach(weapons, id: \.id) { weapon in
                                        WeaponImageView(id: weapon.id)
                                            .aspectRatio(1, contentMode: .fit)
                                            .frame(minWidth: 40, minHeight: 40)
                                            .continuousCornerRadius(8)
                                    }
                                    
                                }
                                
                                Spacer()
                                
                            }
                            .padding(.top)
                            
                        }
                        
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColor.listItemBackgroundColor)
            .continuousCornerRadius(10)
            
        }
    }
}
