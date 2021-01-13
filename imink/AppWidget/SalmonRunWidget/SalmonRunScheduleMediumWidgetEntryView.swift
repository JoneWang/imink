//
//  SalmonRunScheduleMediumWidgetEntryView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/6.
//

import Foundation
import WidgetKit
import SwiftUI
import InkCore

struct SalmonRunScheduleMediumWidgetEntryView : View {
    
    var entry: SalmonRunScheduleProvider.Entry
    
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
        ZStack {
            WidgetBackgroundView(texture: .salmonRunBubble, widgetFamily: entry.family, widgetSize: entry.size)

            VStack(spacing: vSpacing) {
                let schedule = entry.schedules?[0]
                let nextSchedule = entry.schedules?[1]
                
                makeScheduleView(schedule: schedule, isFirst: true)
                
                GeometryReader { geo in
                    Path { path in
                        path.move(to: .init(x: 0, y: 0))
                        path.addLine(to: .init(x: geo.size.width, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
                    .foregroundColor(Color.white.opacity(0.5))
                }
                .frame(height: 1)
                
                makeScheduleView(schedule: nextSchedule)
            }
            .padding(16)
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
                            let weapon = schedule?.weapons?[i]
                            WeaponImageView(id: weapon?.id ?? "")
                                .aspectRatio(contentMode: .fit)
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
    
}
