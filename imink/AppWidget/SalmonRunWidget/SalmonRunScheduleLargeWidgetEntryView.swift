//
//  SalmonRunScheduleLargeWidgetEntryView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/6.
//

import Foundation
import WidgetKit
import SwiftUI

struct SalmonRunScheduleLargeWidgetEntryView : View {
    
    var entry: SalmonRunScheduleProvider.Entry
    
    var topBarHeight: CGFloat {
        var height: CGFloat = 49
        if entry.size == .size291 {
            height = 47
        }
        return height
    }
    
    var topBarSpacing: CGFloat {
        switch entry.size {
        case .size364, .size360, .size348:
            return 17
        case .size338, .size329:
            return 16
        case .size322:
            return 12
        case .size291:
            return 10
        }
    }
    
    var vSpacing: CGFloat {
        switch entry.size {
        case .size364:
            return 13.5
        case .size360:
            return 13
        case .size348:
            return 11
        case .size338:
            return 11.5
        case .size329:
            return 11
        case .size322:
            return 8.5
        case .size291:
            return 9
        }
    }
    
    var titleAndStageSpacing: CGFloat {
        switch entry.size {
        case .size364, .size360:
            return 9
        case .size348, .size338, .size329:
            return 8
        case .size322:
            return 7
        case .size291:
            return 8
        }
    }
    
    var futurePadding: CGFloat {
        switch entry.size {
        case .size364, .size360:
            return 13
        case .size348, .size338:
            return 11
        case .size329, .size322:
            return 10
        case .size291:
            return 8
        }
    }
    
    var futureSpacing: CGFloat {
        switch entry.size {
        case .size364:
            return 10
        case .size360, .size348, .size338:
            return 9
        case .size329, .size322:
            return 8
        case .size291:
            return 6.5
        }
    }
    
    var firstWeaponleading: CGFloat {
        switch entry.size {
        case .size364:
            return 3
        case .size360:
            return 4
        case .size348:
            return 3
        case .size338:
            return 2
        case .size329:
            return 1.5
        case .size322:
            return 1
        case .size291:
            return 2
        }
    }
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()
    
    var body: some View {
        if entry.schedules != nil {
            makeContent()
        } else {
            makeContent()
                .redacted(reason: .placeholder)
        }
    }
    
    func makeContent() -> some View {
        let now = Date()
        return ZStack {
            Rectangle()
                .overlay(
                    GeometryReader { geo in
                        BubbleView(size: geo.size, add: 1)
                            .background(Color("SalmonRunBubbleBackgroundColor"))
                            .foregroundColor(Color("SalmonRunBubbleForegroundColor"))
                            .scaleEffect(geo.size.width / 360, anchor: .topLeading)
                    },
                    alignment: .topLeading
                )
                .unredacted()
            
            VStack(spacing: topBarSpacing) {
                ZStack {
                    Rectangle()
                        .overlay(
                            Image("Topbar")
                                .resizable()
                                .scaledToFill(),
                            alignment: .top
                        )
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Image("SalmonRunMono")
                        Text("Salmon Run")
                            .sp1Font(size: 17)
                        Spacer()
                    }
                    .offset(x: 0, y: 2)
                }
                .frame(height: topBarHeight)
                .clipped()
                .unredacted()
                
                VStack(spacing: vSpacing) {
                    let schedule = entry.schedules?.details.first
                    let nextSchedule = entry.schedules?.details.last
                    
                    makeScheduleView(schedule: schedule)
                    
                    makeLine()
                    
                    makeScheduleView(schedule: nextSchedule)
                    
                    makeLine()
                                        
                    VStack(spacing: titleAndStageSpacing) {
                        HStack(alignment: .bottom) {
                            Text("Future")
                                .sp1Font(size: 14, color: Color("SalmonRunTitleColor"))
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                .unredacted()
                            
                            Spacer()
                        }
                        
                        VStack(spacing: futureSpacing) {
                            ForEach(2..<5) { i in
                                let schedule = entry.schedules?.schedules[i]
                                
                                if i != 2 {
                                    makeLine()
                                        .padding(.bottom, 1)
                                }
                                
                                HStack(alignment: .center) {
                                    Text(schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat) – \(schedule!.endTime, formatter: scheduleTimeFormat)" : "          ")
                                        .sp2Font(size: 12)
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                    
                                    Spacer()
                                    
                                    let hours = Calendar.current.dateComponents([.hour], from: now, to: schedule?.startTime ?? now).hour ?? 0
                                    Text(String(format: "In %d hours".localized, hours))
                                        .sp1Font(size: 14, color: Color(white: 0.8))
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                }
                            }
                        }
                        .padding(futurePadding)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(10)
                    }
                }
                .padding([.leading, .trailing, .bottom], 16)
            }
        }
    }
    
    func makeScheduleView(schedule: SalmonRunSchedules.Schedule?) -> some View {
        var title: LocalizedStringKey = ""
        if let schedule = schedule {
            let now = Date()
            let nextDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
            if now < schedule.startTime {
                title = "Soon!"
            } else if now > schedule.startTime, now < schedule.endTime {
                title = "Open!"
            } else if now > schedule.startTime, nextDate > schedule.endTime {
                title = "Next_salmonrun"
            }
        }
        
        return GeometryReader() { geo in
            VStack(spacing: titleAndStageSpacing) {
                HStack(alignment: .bottom, spacing: 10 + firstWeaponleading) {
                    Text(title)
                        .sp1Font(size: 14, color: Color("SalmonRunTitleColor"))
                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                        .unredacted()
                    
                    Spacer()
                    
                    Text(schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat) – \(schedule!.endTime, formatter: scheduleTimeFormat)" : "")
                        .sp2Font(size: 12)
                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                        .unredacted()
                }
                
                HStack(spacing: 10 + firstWeaponleading) {
                    makeStageImage(
                        stageImageName: "\(schedule?.stage?.name ?? "")_img".localized,
                        stageName: schedule?.stage?.name.localizedKey ?? "            "
                    )
                    .frame(width: (geo.size.width - (10 + firstWeaponleading)) / 2)
                    
                    HStack {
                        ForEach(0..<4) { i in
                            if i != 0 {
                                Spacer()
                            }
                            let weapon = schedule?.weapons?[i]
                            Image("weapon-\(weapon?.id ?? "")")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    }
                }
            }
        }
    }
    
    func makeStageImage(stageImageName: String, stageName: LocalizedStringKey) -> some View {
        Image(stageImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minHeight: 0, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.black.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color("SalmonRunScheduleStageBorderColor"), lineWidth: 1)
                    )
                    .opacity(0.4)
            )
            .overlay(Text(stageName).sp2Font(), alignment: .center)
            .cornerRadius(6)
            .clipped()
    }
    
    func makeLine() -> some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: .init(x: 0, y: 0))
                path.addLine(to: .init(x: geo.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
            .foregroundColor(Color.white.opacity(0.5))
        }
        .frame(height: 1)
    }
    
}
