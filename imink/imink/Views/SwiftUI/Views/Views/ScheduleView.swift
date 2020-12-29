//
//  ScheduleView.swift
//  imink
//
//  Created by Jone Wang on 2020/10/2.
//

import SwiftUI
import SDWebImageSwiftUI

struct ScheduleView: View {
    
    let regularSchedules: [Schedules.Schedule]
    let gachiSchedules: [Schedules.Schedule]
    let leagueSchedules: [Schedules.Schedule]
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        let schedules = [regularSchedules, gachiSchedules, leagueSchedules]
        let gameModeColors: [Color] = [AppColor.spLightGreen, AppColor.spOrange, AppColor.spPink]
        let gameModeImageNames: [String] = ["RegularBattle", "RankedBattle", "LeagueBattle"]
        let calendar = NSCalendar.current
        
        LazyVGrid(
            columns: [GridItem(.flexible())]
        ) {
            
            ForEach(0..<regularSchedules.count, id: \.self) { (index: Int) in
                
                VStack {
                    
                    if let schedule = schedules.first?[index] {
                        let scheduleTime = schedule.startTime
                        
                        VStack {
                            Text(index == 0 ?
                                    LocalizedStringKey("Now") :
                                    "\(calendar.isDateInToday(scheduleTime) ? "" : "\(NSLocalizedString("Next Day", comment: "")) ")\(scheduleTime, formatter: scheduleTimeFormat)")
                                .sp2Font(size: 15, color: AppColor.appLabelColor)
                                .colorInvert()
                        }
                        .padding(3)
                        .padding(.horizontal)
                        .background(Color.secondary)
                        .clipShape(Capsule())
                        .padding(.bottom, 5)
                    }
                    
                    HStack {
                        
                        ForEach(0..<3) { j in
                            let schedule = schedules[j][index]
                            
                            VStack {
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(schedule.gameMode.imageName)
                                        .resizable()
                                        .aspectRatio(1, contentMode: .fill)
                                        .frame(width: 20)
                                    Text(schedule.rule.name.localizedKey)
                                        .sp1Font(color: gameModeColors[j])
                                        .minimumScaleFactor(0.5)
                                }
                                
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        ForEach(0..<3) { j in
                            let schedule = schedules[j][index]
                            
                            VStack(spacing: 8) {
                                ForEach(0..<2) { k in
                                    let stage = [schedule.stageA, schedule.stageB][k]
                                    
                                    Text(stage.name.localizedKey)
                                        .sp2Font(color: AppColor.appLabelColor)
                                        .minimumScaleFactor(0.5)
                                    
                                    WebImage(url: stage.image)
                                        .resizable()
                                        .aspectRatio(640 / 360, contentMode: .fill)
                                        .continuousCornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.primary, lineWidth: 1)
                                        )
                                    
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(AppColor.listItemBackgroundColor)
                .continuousCornerRadius(10)
            }
            .padding(0)
        }
    }
    
}
