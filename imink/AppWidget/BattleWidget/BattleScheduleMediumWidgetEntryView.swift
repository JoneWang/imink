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
        default:
            return 8
        }
    }
    
    var background: some View {
        switch gameMode {
        case .regular:
            return WidgetBackgroundView(texture: .regularStreak, widgetFamily: entry.family, widgetSize: entry.size)
        case .gachi:
            return WidgetBackgroundView(texture: .rankStreak, widgetFamily: entry.family, widgetSize: entry.size)
        case .league:
            return WidgetBackgroundView(texture: .leagueStreak, widgetFamily: entry.family, widgetSize: entry.size)
        }
    }
    
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
            background
            
            VStack(spacing: vSpacing) {
                let schedule = entry.schedules?[0]
                let nextSchedule = entry.schedules?[1]
                
                HStack(spacing: 10) {
                    VStack(spacing: titleAndStageSpacing) {
                        HStack {
                            Text("Now")
                                .sp1Font(size: 14)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                .unredacted()
                            
                            Spacer()
                        }
                        
                        makeStageImage(
                            stageId: schedule?.stageA.id ?? "0",
                            stageName: schedule?.stageA.name.localizedKey ?? "            "
                        )
                    }
                    
                    VStack(spacing: titleAndStageSpacing) {
                        HStack(spacing: 6) {
                            Spacer()
                            
                            Text(schedule?.rule.name.localizedKey ?? "      ")
                                .sp1Font(size: 14, color: .white)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            
                            if let imageName = schedule?.rule.imageName {
                                Image(imageName)
                                     .fixedSize()
                                     .frame(width: 20, height:14, alignment: .center)
                            }
                        }
                        
                        makeStageImage(
                            stageId: schedule?.stageB.id ?? "0",
                            stageName: schedule?.stageB.name.localizedKey ?? "            "
                        )
                    }
                }
                
                GeometryReader { geo in
                    Path { path in
                        path.move(to: .init(x: 0, y: 0))
                        path.addLine(to: .init(x: geo.size.width, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
                    .foregroundColor(Color.white.opacity(0.5))
                }
                .frame(height: 1)
                
                HStack(spacing: 10) {
                    VStack(spacing: titleAndStageSpacing) {
                        HStack {
                            Text(nextSchedule?.startTime != nil ? "\(nextSchedule!.startTime, formatter: scheduleTimeFormat)" : "     ")
                                .sp1Font(size: 14)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                .unredacted()
                            
                            Spacer()
                        }
                        
                        makeStageImage(
                            stageId: nextSchedule?.stageA.id ?? "0",
                            stageName: nextSchedule?.stageA.name.localizedKey ?? "            "
                        )
                    }
                    
                    VStack(spacing: titleAndStageSpacing) {
                        HStack(spacing: 6) {
                            Spacer()
                            
                            Text(nextSchedule?.rule.name.localizedKey ?? "      ")
                                .sp1Font(size: 14, color: .white)
                                .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            
                            if let imageName = nextSchedule?.rule.imageName {
                                Image(imageName)
                                     .fixedSize()
                                     .frame(width: 20, height:14, alignment: .center)
                            }
                        }
                        
                        makeStageImage(
                            stageId: nextSchedule?.stageB.id ?? "0",
                            stageName: nextSchedule?.stageB.name.localizedKey ?? "            "
                        )
                    }
                }
            }
            .padding(16)
        }
    }
    
    func makeStageImage(stageId: String, stageName: LocalizedStringKey) -> some View {
        var borderColor = Color("RegularScheduleStageBorderColor")
        switch gameMode {
        case .gachi:
            borderColor = Color("RankedScheduleStageBorderColor")
        case .league:
            borderColor = Color("LeagueScheduleStageBorderColor")
        case .regular:
            borderColor = Color("RegularScheduleStageBorderColor")
        }
        
        return StageImageView(id: stageId)
            .aspectRatio(contentMode: .fill)
            .frame(minHeight: 0, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .foregroundColor(Color.black.opacity(0.75))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(borderColor, lineWidth: 1)
                    )
                    .opacity(0.4)
            )
            .overlay(Text(stageName).sp2Font(), alignment: .center)
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
