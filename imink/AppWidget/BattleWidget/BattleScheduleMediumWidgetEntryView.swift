//
//  BattleScheduleMediumWidgetEntryView.swift
//  imink
//
//  Created by Jone Wang on 2020/10/17.
//

import Foundation
import WidgetKit
import SwiftUI
import InkCore

struct BattleScheduleMediumWidgetEntryView : View {
    @Environment(\.widgetSize) var widgetSize: CGSize
    
    var entry: BattleScheduleProvider.Entry
    var gameMode: BattleScheduleWidgetGameMode
    
    var body: some View {
        if entry.schedules != nil {
            makeContent()
        } else {
            makeContent()
                .redacted(reason: .placeholder)
        }
    }
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func makeContent() -> some View {
        ZStack {
            gameMode.background
            
            VStack() {
                let schedule = entry.schedules?[0]
                let nextSchedule = entry.schedules?[1]
                
                VStack(spacing: titleAndStageSpacing) {
                    HStack {
                        Text("Now")
                            .sp1Font(size: titleFontSize)
                            .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            .unredacted()
                        
                        Spacer()
                        HStack(spacing: 6) {
                            Text(gameMode.localizedName)
                                .sp1Font(size: titleFontSize, color: .white)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            Text(schedule?.rule.localizedName ?? "      ")
                                .sp1Font(size: titleFontSize, color: .white)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            
                            if let imageName = schedule?.rule.imageName {
                                Image(imageName)
                                     .fixedSize()
                                     .frame(width:ruleIconWidth, height:ruleIconHeight, alignment: .center)
                            }
                        }
                    }
                    
                    HStack {
                        makeStageImage(
                            stageHeight: stageHeight,
                            stageNameFontSize: stageNameFontSize,
                            stageId: schedule?.stageA.id ?? "0",
                            stageName: schedule?.stageA.localizedName ?? "            "
                        )
                        
                        makeStageImage(
                            stageHeight: stageHeight,
                            stageNameFontSize: stageNameFontSize,
                            stageId: schedule?.stageB.id ?? "0",
                            stageName: schedule?.stageB.localizedName ?? "            "
                        )
                    }
                }
                
                Spacer()
                
                Path { path in
                    path.move(to: .init(x: 0, y: 0))
                    path.addLine(to: .init(x: widgetSize.width - 32, y: 0))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
                .foregroundColor(Color.white.opacity(0.5))
                .frame(height: 1)
                
                Spacer()
                
                VStack(spacing: titleAndStageSpacing) {
                    HStack {
                        Text(nextSchedule?.startTime != nil ? "\(nextSchedule!.startTime, formatter: scheduleTimeFormat)" : "     ")
                            .sp1Font(size: titleFontSize)
                            .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            .unredacted()
                        
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Text(nextSchedule?.rule.localizedName ?? "      ")
                                .sp1Font(size: titleFontSize, color: .white)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            
                            if let imageName = nextSchedule?.rule.imageName {
                                Image(imageName)
                                     .fixedSize()
                                     .frame(width:ruleIconWidth, height:ruleIconHeight, alignment: .center)
                            }
                        }
                    }
                    
                    HStack {
                        makeStageImage(
                            stageHeight: stageHeight,
                            stageNameFontSize: stageNameFontSize,
                            stageId: nextSchedule?.stageA.id ?? "0",
                            stageName: nextSchedule?.stageA.localizedName ?? "            "
                        )
                        
                        makeStageImage(
                            stageHeight: stageHeight,
                            stageNameFontSize: stageNameFontSize,
                            stageId: nextSchedule?.stageB.id ?? "0",
                            stageName: nextSchedule?.stageB.localizedName ?? "            "
                        )
                    }
                }
                .padding(.top, -2)
            }
            .padding(16)
        }
    }
    
    func makeStageImage(stageHeight: CGFloat, stageNameFontSize: CGFloat, stageId: String, stageName: String) -> some View {
        ImageView.stage(id: stageId)
            .aspectRatio(contentMode: .fill)
            .frame(height: stageHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.black.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(gameMode.stageBorderColor, lineWidth: 1)
                    )
                    .opacity(0.4)
            )
            .overlay(Text(stageName).sp2Font(size: stageNameFontSize), alignment: .center)
            .continuousCornerRadius(6)
            .clipped()
    }
}

extension BattleScheduleMediumWidgetEntryView {
    var titleFontSize: CGFloat { widgetSize.width <= 306 ? 13 : 14 }
    var ruleIconWidth: CGFloat { widgetSize.width <= 306 ? 19 : 20 }
    var ruleIconHeight: CGFloat { widgetSize.width <= 306 ? 13 : 14 }
    var titleAndStageSpacing: CGFloat { (widgetSize.width * 0.023).rounded() }

    var stageHeight: CGFloat { (((widgetSize.width - 42) / 2) * 0.1985).rounded() }
    var stageNameFontSize: CGFloat { widgetSize.width <= 306 ? 11 : 12 }
}

extension GameRule {
    
    var imageName: String {
        switch key {
        case .clamBlitz:
            return "ClamBlitz"
        case .turfWar:
            return "TurfWar"
        case .splatZones:
            return "SplatZones"
        case .towerControl:
            return "TowerControl"
        case .rainmaker:
            return "Rainmaker"
        }
    }
    
}

import SplatNet2API

struct BattleScheduleMediumWidgetEntryView_Previews: PreviewProvider {
    static let widgetFamily = WidgetFamily.systemMedium
    static let gameMode = BattleScheduleWidgetGameMode.gachi
    
    static var previews: some View {
        ForEach(WidgetDevice.allCases, id: \.self) { size in
            BattleScheduleWidgetEntryView(entry: entry, gameMode: gameMode)
                .previewContext(WidgetPreviewContext(family: widgetFamily))
                .previewDevice(PreviewDevice(stringLiteral: size.rawValue))
                .previewDisplayName("\(size)")
        }
    }
    
    static var entry: BattleScheduleProvider.Entry {
        let sampleData = SplatNet2API.schedules.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let schedules = json.decode(Schedules.self)!
        let entry = BattleScheduleProvider.Entry(
            date: Date(),
            schedules: schedules.gachi)
        return entry
    }
}
