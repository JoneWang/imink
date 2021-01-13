//
//  SalmonRunScheduleLargeWidgetEntryView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/6.
//

import Foundation
import WidgetKit
import SwiftUI
import InkCore

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
    
    var topbarTitleOffset: CGFloat {
        switch entry.size {
        case .size364, .size338:
            return 1
        default:
            return 0
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
    
    var titleFontSize: CGFloat {
        switch entry.size {
        case .size291:
            return 13
        default:
            return 14
        }
    }
    
    var timeFontSize: CGFloat {
        switch entry.size {
        case .size291:
            return 11
        default:
            return 12
        }
    }
    
    var futureTimeFontSize: CGFloat {
        switch entry.size {
        case .size291:
            return 10
        default:
            return 12
        }
    }
    
    var futureInHoursFontSize: CGFloat {
        switch entry.size {
        case .size291:
            return 12
        default:
            return 14
        }
    }
    
    var futureAreaHeight: CGFloat {
        switch entry.size {
        case .size364:
            return 110
        case .size360:
            return 106
        case .size348:
            return 103
        case .size338:
            return 101
        case .size329:
            return 96
        case .size322:
            return 92
        case .size291:
            return 77
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
        let now = self.entry.date
        return ZStack {
            WidgetBackgroundView(texture: .salmonRunBubble, widgetFamily: entry.family, widgetSize: entry.size)

            VStack(spacing: topBarSpacing) {
                ZStack {
                    WidgetBackgroundView(texture: .topbarBubble, widgetFamily: entry.family, widgetSize: entry.size)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Image("SalmonRunMono")
                        Text("Salmon Run")
                            .sp1Font(size: 17)
                            .padding(.bottom, topbarTitleOffset)
                        Spacer()
                    }
                    .offset(x: 0, y: 2)
                }
                .frame(height: topBarHeight)
                .clipped()
                .unredacted()
                
                VStack(spacing: vSpacing) {
                    let schedule = entry.schedules?[0]
                    let nextSchedule = entry.schedules?[1]
                    
                    makeScheduleView(schedule: schedule, isFirst: true)
                    
                    makeLine()
                    
                    makeScheduleView(schedule: nextSchedule)
                    
                    makeLine()
                                        
                    VStack(spacing: titleAndStageSpacing) {
                        HStack(alignment: .bottom) {
                            Text("Future")
                                .sp1Font(size: titleFontSize, color: Color.white)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                .unredacted()
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .center, spacing: 0) {
                            ForEach(2..<5) { i in
                                let schedule = entry.schedules?[i]
                                
                                if i != 2 {
                                    makeLine().padding(.bottom, 1)
                                }
                                
                                Spacer()
                                
                                HStack(alignment: .center) {
                                    Text(schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat) – \(schedule!.endTime, formatter: scheduleTimeFormat)" : "          ")
                                        .sp2Font(size: futureTimeFontSize)
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                    
                                    Spacer()
                                    
                                    let hours = Calendar.current.dateComponents([.hour], from: now, to: schedule?.startTime ?? now).hour ?? 0
                                    Text(String(format: "In %d hours".localized, hours))
                                        .sp1Font(size: futureInHoursFontSize, color: Color(white: 0.8))
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                }
                                
                                Spacer()
                            }
                        }
                        .padding([.leading, .trailing], futurePadding)
                        .frame(height: futureAreaHeight)
                        .background(Color.black.opacity(0.6))
                        .continuousCornerRadius(10)
                    }
                }
                .padding([.leading, .trailing, .bottom], 16)
            }
        }
    }
    
    func makeScheduleView(schedule: SalmonRunSchedules.Schedule?, isFirst: Bool = false) -> some View {
        var title: LocalizedStringKey = ""
        if let schedule = schedule {
            let now = self.entry.date
            
            if isFirst {
                if now < schedule.startTime {
                    title = "Soon!"
                } else {
                    title = "Open!"
                }
            } else {
                title = "Next_salmonrun"
            }
        }
        
        return GeometryReader() { geo in
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 10 + firstWeaponleading) {
                    Text(title)
                        .sp1Font(size: titleFontSize, color: Color.white)
                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                        .unredacted()
                    
                    Spacer()
                    
                    Text(schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat) – \(schedule!.endTime, formatter: scheduleTimeFormat)" : "")
                        .sp2Font(size: timeFontSize)
                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                        .unredacted()
                }
                
                Spacer()
                
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
                            if let weapon = schedule?.weapons?[i] {
                                WeaponImageView(id: weapon.id)
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func makeStageImage(stageImageName: String, stageName: LocalizedStringKey) -> some View {
        SalomonRunStageImageView(name: stageImageName)
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
            .continuousCornerRadius(6)
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
