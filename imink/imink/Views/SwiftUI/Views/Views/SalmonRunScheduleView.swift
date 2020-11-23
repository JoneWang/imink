//
//  SalmonRunScheduleView.swift
//  imink
//
//  Created by 王强 on 2020/10/6.
//

import SwiftUI
import SDWebImageSwiftUI

struct SalmonRunScheduleView: View {
    let schedules: SP2SalmonRunSchedules
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
    
    private var dataSource: [SP2SalmonRunSchedules.Schedule] {
        schedules.schedules.map { schedule in
            if let schedule = schedules.details.first(where: { $0.startTime == schedule.startTime }) {
                return schedule
            }
            
            return schedule
        }
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
                                .sp2Font(color: Color.primary)
                            
                            WebImage(url: stage.image)
                                .resizable()
                                .aspectRatio(640 / 360, contentMode: .fill)
                                .frame(minWidth: 100)
                                .cornerRadius(8)
                                .padding(.top)
                            
                        }
                        
                        VStack(spacing: 0) {
                            
                            Text("Supplied Weapons")
                                .sp2Font(color: Color.primary)
                            
                            VStack {
                                
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    
                                    ForEach(weapons, id: \.id) { weapon in
                                        if let thumbnailURL = weapon.weapon?.thumbnail {
                                            WebImage(url: thumbnailURL)
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(minWidth: 40)
                                                .cornerRadius(8)
                                        }
                                        else if let imageURL = weapon.coopSpecialWeapon?.image {
                                            WebImage(url: imageURL)
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .frame(minWidth: 40)
                                                .cornerRadius(8)
                                        }
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
            .cornerRadius(10)
            
        }
    }
}
