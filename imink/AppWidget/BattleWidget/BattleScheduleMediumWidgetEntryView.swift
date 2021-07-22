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
        GeometryReader() { geo in
            ZStack {
                if gameMode == .regular {
                    WidgetBackgroundView(texture: .regularStreak, widgetFamily: entry.family, widgetSize: geo.size)
                } else if gameMode == .gachi {
                    WidgetBackgroundView(texture: .rankStreak, widgetFamily: entry.family, widgetSize: geo.size)
                } else if gameMode == .league {
                    WidgetBackgroundView(texture: .leagueStreak, widgetFamily: entry.family, widgetSize: geo.size)
                }
                
                let titleFontSize: CGFloat = geo.size.width <= 306 ? 13 : 14
                let ruleIconWidth: CGFloat = geo.size.width <= 306 ? 19 : 20
                let ruleIconHeight: CGFloat = geo.size.width <= 306 ? 13 : 14
                let titleAndStageSpacing = (geo.size.width * 0.023).rounded()
                
                let stageHeight = (((geo.size.width - 42) / 2) * 0.1985).rounded()
                let stageNameFontSize: CGFloat = geo.size.width <= 306 ? 11 : 12
                
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
                    
                    GeometryReader { geo in
                        Path { path in
                            path.move(to: .init(x: 0, y: 0))
                            path.addLine(to: .init(x: geo.size.width, y: 0))
                        }
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
                        .foregroundColor(Color.white.opacity(0.5))
                    }
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
    }
    
    func makeStageImage(stageHeight: CGFloat, stageNameFontSize: CGFloat, stageId: String, stageName: String) -> some View {
        var borderColor = Color("RegularScheduleStageBorderColor")
        switch gameMode {
        case .gachi:
            borderColor = Color("RankedScheduleStageBorderColor")
        case .league:
            borderColor = Color("LeagueScheduleStageBorderColor")
        case .regular:
            borderColor = Color("RegularScheduleStageBorderColor")
        }
        
        return ImageView.stage(id: stageId)
            .aspectRatio(contentMode: .fill)
            .frame(height: stageHeight)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.black.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )
                    .opacity(0.4)
            )
            .overlay(Text(stageName).sp2Font(size: stageNameFontSize), alignment: .center)
            .continuousCornerRadius(6)
            .clipped()
    }
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
        ForEach(WidgetSize.allCases, id: \.self) { size in
            BattleScheduleWidgetEntryView(entry: genEntry(with: size), gameMode: gameMode)
                .previewContext(WidgetPreviewContext(family: widgetFamily))
                .previewDevice(PreviewDevice(stringLiteral: size.deviceName))
                .previewDisplayName("\(size.cgSize(with: widgetFamily).width) \(size.deviceName)")
        }
    }
    
    static func genEntry(with size: WidgetSize) -> BattleScheduleProvider.Entry {
        let sampleData = SplatNet2API.schedules.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let schedules = json.decode(Schedules.self)!
        let entry = BattleScheduleProvider.Entry(
            date: Date(),
            schedules: schedules.gachi,
            size: size,
            family: widgetFamily)
        return entry
    }
}
