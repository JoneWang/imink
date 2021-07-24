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
        return GeometryReader() { geo in
            ZStack {
                WidgetBackgroundView(texture: .salmonRunBubble, widgetFamily: entry.family, widgetSize: geo.size)
                
                let topBarHeight = round(((geo.size.width - 42) / 2) * 0.3035)
                let topBarFontSize: CGFloat = geo.size.width <= 306 ? 15 : 17
                let topBarTitleOffset: CGFloat = geo.size.width == 364 || geo.size.width == 338 ? 1 : 0
                let titleIconHeight: CGFloat = geo.size.width <= 306 ? 19.5 : 22
                
                let titleFontSize: CGFloat = geo.size.width <= 306 ? 13 : 14
                let timeFontSize: CGFloat = geo.size.width <= 306 ? 11 : 12
                let titleAndStageSpacing = (geo.size.width * 0.023).rounded()
                
                let stageWidth = (geo.size.width - 42) / 2
                let stageHeight = (((geo.size.width - 42) / 2) * 0.1985).rounded()
                let stageNameFontSize: CGFloat = geo.size.width <= 306 ? 11 : 12
                
                let makeLineOffset: CGFloat = geo.size.height <= 306 ? -2 : 0
                
                let futureTimeFontSize: CGFloat = geo.size.width <= 322 ? 11 : 12
                let futureInHoursFontSize: CGFloat = geo.size.width <= 322 ? 13 : 14
                let futureSpacingAndPadding: CGFloat = geo.size.width <= 306 ? 9 : geo.size.width >= 360 ? 11 : 10

            VStack(spacing: 0) {
                ZStack {
                    WidgetBackgroundView(texture: .topbarBubble, widgetFamily: entry.family, widgetSize: geo.size)
                    
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
                    
                    makeScheduleView(titleFontSize:titleFontSize, timeFontSize:timeFontSize, titleAndStageSpacing:titleAndStageSpacing, stageWidth:stageWidth, stageHeight:stageHeight, stageNameFontSize:stageNameFontSize, schedule: schedule, isFirst: true)
                    
                    Spacer()
                        .foregroundColor(Color.blue)
                    
                    makeLine().padding(.top, 3 + makeLineOffset).padding(.bottom, 1 + makeLineOffset)
                    
                    Spacer()
                    
                    makeScheduleView(titleFontSize:titleFontSize, timeFontSize:timeFontSize, titleAndStageSpacing:titleAndStageSpacing, stageWidth:stageWidth, stageHeight:stageHeight, stageNameFontSize:stageNameFontSize, schedule: nextSchedule)
                    
                    Spacer()
                    
                    makeLine().padding(.top, 3 + makeLineOffset).padding(.bottom, 1 + makeLineOffset)
                    
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
                                    makeLine().padding(.bottom, 0)
                                }
                                
                                Spacer()
                                    .frame(maxHeight:futureSpacingAndPadding)
                                
                                HStack(alignment: .center) {
                                    Text(schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat) – \(schedule!.endTime, formatter: scheduleTimeFormat)" : "          ")
                                        .sp2Font(size: futureTimeFontSize)
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                    
                                    Spacer()
                                    
                                    let hours = Calendar.current.dateComponents([.hour], from: now, to: schedule?.startTime ?? now).hour ?? 0
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
    }
    
    func makeScheduleView(titleFontSize: CGFloat, timeFontSize: CGFloat, titleAndStageSpacing: CGFloat, stageWidth: CGFloat, stageHeight: CGFloat, stageNameFontSize: CGFloat, schedule: SalmonRunSchedules.Schedule?, isFirst: Bool = false) -> some View {
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

import SplatNet2API

struct SalmonRunScheduleLargeWidgetEntryView_Previews: PreviewProvider {
    static let widgetFamily = WidgetFamily.systemLarge
    
    static var previews: some View {
        ForEach(WidgetSize.allCases, id: \.self) { size in
            SalmonRunScheduleWidgetEntryView(entry: genEntry(with: size))
                .previewContext(WidgetPreviewContext(family: widgetFamily))
                .previewDevice(PreviewDevice(stringLiteral: size.deviceName))
                .previewDisplayName("\(size.cgSize(with: widgetFamily).width) \(size.deviceName)")
        }
    }
    
    static func genEntry(with size: WidgetSize) -> SalmonRunScheduleProvider.Entry {
        let sampleData = SplatNet2API.salmonRunSchedules.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let salmonRunSchedules = json.decode(SalmonRunSchedules.self)!
        let entry = SalmonRunScheduleProvider.Entry(
            date: Date(),
            schedules: salmonRunSchedules.details + salmonRunSchedules.schedules,
            size: size,
            family: widgetFamily)
        return entry
    }
}
