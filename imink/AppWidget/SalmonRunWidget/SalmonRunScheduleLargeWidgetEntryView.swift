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
    @Environment(\.widgetSize) var widgetSize: CGSize
    
    var entry: SalmonRunScheduleProvider.Entry
    
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
            WidgetBackgroundView(texture: .salmonRunBubble)

            VStack(spacing: 0) {
                ZStack {
                    WidgetBackgroundView(texture: .topbarBubble)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Image("SalmonRunMono")
                            .resizable()
                            .scaledToFit()
                            .frame(height:titleIconHeight, alignment: .center)
                        Text("Salmon Run")
                            .sp1Font(size: topBarFontSize)
                            .padding(.bottom, topBarTitleOffset)
                        Spacer()
                    }
                    .offset(x: 0, y: 2)
                }
                .frame(height: topBarHeight)
                .clipped()
                .unredacted()
                
                VStack() {
                    let schedule = entry.schedules?[0]
                    let nextSchedule = entry.schedules?[1]
                    
                    makeScheduleView(schedule: schedule, isFirst: true)
                    
                    Spacer()
                        .foregroundColor(Color.blue)
                    
                    makeLine()
                        .padding(.top, 3 + makeLineOffset)
                        .padding(.bottom, 1 + makeLineOffset)
                    
                    Spacer()
                    
                    makeScheduleView(schedule: nextSchedule)
                    
                    Spacer()
                    
                    makeLine()
                        .padding(.top, 3 + makeLineOffset)
                        .padding(.bottom, 1 + makeLineOffset)
                    
                    Spacer()
                                        
                    VStack(spacing: titleAndStageSpacing) {
                        HStack(alignment: .bottom) {
                            Text("Future")
                                .sp1Font(size: titleFontSize, color: Color("SalmonRunTitleColor"))
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                .unredacted()
                            
                            Spacer()
                        }
                        
                        VStack(alignment: .center, spacing: 0) {
                            ForEach(2..<5) { i in
                                let schedule = entry.schedules?[i]
                                
                                if i != 2 {
                                    makeLine()
                                        .padding(.bottom, 0)
                                }
                                
                                Spacer()
                                    .frame(maxHeight:futureSpacingAndPadding)
                                
                                HStack(alignment: .center) {
                                    Text(schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat) – \(schedule!.endTime, formatter: scheduleTimeFormat)" : "          ")
                                        .sp2Font(size: futureTimeFontSize)
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                    
                                    Spacer()
                                    
                                    let hours = Calendar.current.dateComponents([.hour], from: entry.date, to: schedule?.startTime ?? entry.date).hour ?? 0
                                    Text(String(format: "In %d hours".localized, hours))
                                        .sp1Font(size: futureInHoursFontSize, color: Color(white: 0.8))
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                        .padding(.top, -1)
                                }
                                
                                Spacer()
                                    .frame(maxHeight:futureSpacingAndPadding)
                            }
                        }
                        .padding([.leading, .trailing], futureSpacingAndPadding)
                        .padding([.top, .bottom], 1)
                        .background(Color.black.opacity(0.6))
                        .continuousCornerRadius(10)
                    }
                }
                .padding([.leading, .trailing, .bottom], 16)
                .padding(.top, 15)
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
                    stageNameFontSize: stageNameFontSize,
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
    
    func makeStageImage(stageImageName: String, stageNameFontSize: CGFloat, stageName: String) -> some View {
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

extension SalmonRunScheduleLargeWidgetEntryView {
    var topBarHeight: CGFloat { round(((widgetSize.width - 42) / 2) * 0.3035) }
    var topBarFontSize: CGFloat { widgetSize.width <= 306 ? 15 : 17 }
    var topBarTitleOffset: CGFloat { widgetSize.width == 364 || widgetSize.width == 338 ? 1 : 0 }
    var titleIconHeight: CGFloat { widgetSize.width <= 306 ? 19.5 : 22 }
    
    var titleFontSize: CGFloat { widgetSize.width <= 306 ? 13 : 14 }
    var timeFontSize: CGFloat { widgetSize.width <= 306 ? 11 : 12 }
    var titleAndStageSpacing: CGFloat { (widgetSize.width * 0.023).rounded() }
    
    var stageWidth: CGFloat { (widgetSize.width - 42) / 2 }
    var stageHeight: CGFloat { (((widgetSize.width - 42) / 2) * 0.1985).rounded() }
    var stageNameFontSize: CGFloat { widgetSize.width <= 306 ? 11 : 12 }
    
    var makeLineOffset: CGFloat { widgetSize.height <= 306 ? -2 : 0 }
    
    var futureTimeFontSize: CGFloat { widgetSize.width <= 322 ? 11 : 12 }
    var futureInHoursFontSize: CGFloat { widgetSize.width <= 322 ? 13 : 14 }
    var futureSpacingAndPadding: CGFloat {widgetSize.width <= 306 ? 9 : widgetSize.width >= 360 ? 11 : 10 }
}

import SplatNet2API

struct SalmonRunScheduleLargeWidgetEntryView_Previews: PreviewProvider {
    static let widgetFamily = WidgetFamily.systemLarge
    
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
            schedules: salmonRunSchedules.details + salmonRunSchedules.schedules)
        return entry
    }
}
