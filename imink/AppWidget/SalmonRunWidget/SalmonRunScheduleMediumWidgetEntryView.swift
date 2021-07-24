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
    @Environment(\.widgetSize) var widgetSize: CGSize
    
    var entry: SalmonRunScheduleProvider.Entry
        
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter
    }()

    var body: some View {
        ZStack {
            WidgetBackgroundView(texture: .salmonRunBubble)
            
            if entry.schedules != nil {
                makeContent()
            } else {
                makeContent()
                    .redacted(reason: .placeholder)
            }
        }
    }
    
    func makeContent() -> some View {
        let schedule = entry.schedules?[0]
        let nextSchedule = entry.schedules?[1]

        return VStack() {
            makeScheduleView(schedule: schedule, isFirst: true)
            
            Spacer()
            
            Path { path in
                path.move(to: .init(x: 0, y: 0))
                path.addLine(to: .init(x: widgetSize.width - 32, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
            .foregroundColor(Color.white.opacity(0.5))
            .frame(height: 1)
            
            Spacer()
            
            makeScheduleView(schedule: nextSchedule)
                .padding(.top, -2)
        }
        .padding(16)
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
        
        return VStack(spacing: titleAndStageSpacing) {
            HStack(alignment: .center, spacing: 10) {
                Text(title)
                    .sp1Font(size: titleFontSize, color: Color("SalmonRunTitleColor"))
                    .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                    .unredacted()
                
                Spacer()
                
                Text(schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat) – \(schedule!.endTime, formatter: scheduleTimeFormat)" : "")
                    .sp2Font(size: timeFontSize)
                    .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                    .unredacted()
                    .padding(.top, 1)
            }
            
            HStack() {
                makeStageImage(
                    stageImageName: schedule?.stage?.imageName ?? "",
                    stageName: schedule?.stage?.localizedName ?? "            "
                )
                .frame(width: stageWidth, height: stageHeight)
                
                Spacer()
                
                ForEach(0..<4) { i in
                    if i != 0 {
                        Spacer()
                    }
                    let weapon = schedule?.weapons?[i]
                    ImageView.weapon(id: weapon?.id ?? "")
                        .aspectRatio(contentMode: .fit)
                        .frame(width: stageHeight, height: stageHeight)
                }
                
            }
        }
    }
    
    func makeStageImage(stageImageName: String, stageName: String) -> some View {
        ImageView.salomonRunStage(name: stageImageName)
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
            .overlay(Text(stageName).sp2Font(size: stageNameFontSize), alignment: .center)
            .continuousCornerRadius(6)
            .clipped()
    }
    
}

extension SalmonRunScheduleMediumWidgetEntryView {
    var titleFontSize: CGFloat { widgetSize.width <= 306 ? 13 : 14 }
    var timeFontSize: CGFloat { widgetSize.width <= 306 ? 11 : 12 }
    var titleAndStageSpacing: CGFloat { (widgetSize.width * 0.023).rounded() }
    
    var stageWidth: CGFloat { (widgetSize.width - 42) / 2 }
    var stageHeight: CGFloat { (((widgetSize.width - 42) / 2) * 0.1985).rounded() }
    var stageNameFontSize: CGFloat { widgetSize.width <= 306 ? 11 : 12 }
}

import SplatNet2API

struct SalmonRunScheduleMediumWidgetEntryView_Previews: PreviewProvider {
    static let widgetFamily = WidgetFamily.systemMedium
    
    static var previews: some View {
        ForEach(WidgetDevice.allCases, id: \.self) { size in
            SalmonRunScheduleWidgetEntryView(entry: entry)
                .previewContext(WidgetPreviewContext(family: widgetFamily))
                .previewDevice(PreviewDevice(stringLiteral: size.rawValue))
                .previewDisplayName("\(size)")
        }
    }
    
    static var entry: SalmonRunScheduleProvider.Entry {
        let sampleData = SplatNet2API.salmonRunSchedules.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let salmonRunSchedules = json.decode(SalmonRunSchedules.self)!
        let entry = SalmonRunScheduleProvider.Entry(
            date: Date(),
            schedules: salmonRunSchedules.details)
        return entry
    }
}
