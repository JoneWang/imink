//
//  ScheduleView.swift
//  imink
//
//  Created by 王强 on 2020/10/2.
//

import SwiftUI
import SDWebImageSwiftUI

struct ScheduleView: View {
    
    let regularSchedules: [SP2Schedule]
    let gachiSchedules: [SP2Schedule]
    let leagueSchedules: [SP2Schedule]
    
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
            columns: [GridItem(.flexible())],
            alignment: .center
        ) {
            
            ForEach(0..<regularSchedules.count, id: \.self) { (index: Int) in
                
                VStack {
                    
                    if let schedule = schedules.first?[index] {
                        let scheduleTime = Date(timeIntervalSince1970: schedule.startTime)
                        
                        VStack {
                            Text(index == 0 ?
                                    "Now" :
                                    "\(calendar.isDateInToday(scheduleTime) ? "" : "Next Day ")\(scheduleTime, formatter: scheduleTimeFormat)")
                                .sp2Font(size: 15, color: Color.primary)
                                .colorInvert()
                        }
                        .padding(3)
                        .padding(.horizontal)
                        .background(Color.secondary)
                        .clipShape(Capsule())
                        .padding(.bottom, 5)
                    }
                    
                    HStack {
                        
                        ForEach(0..<3) { i in
                            VStack {
                                Spacer()
                                Image(gameModeImageNames[i])
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fill)
                                    .frame(width: 20)
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
                                    
                                    Text(stage.name)
                                        .sp2Font(color: gameModeColors[j])
                                        .minimumScaleFactor(0.5)
                                    
                                    WebImage(url: stage.imageURL)
                                        .resizable()
                                        .aspectRatio(640 / 360, contentMode: .fill)
                                        .cornerRadius(8)
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
                .background(Color.primary.opacity(0.1))
                .cornerRadius(10)
                .padding(.top, 15)
            }
        }
        .padding([.leading, .trailing, .bottom])
        .padding(.top, 30)
    }
    
}
