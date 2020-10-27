//
//  BattleScheduleMediumWidgetEntryView.swift
//  imink
//
//  Created by Jone Wang on 2020/10/17.
//

import Foundation
import WidgetKit
import SwiftUI

struct BattleScheduleMediumWidgetEntryView : View {
    var entry: BattleScheduleProvider.Entry
    var gameMode: BattleScheduleWidgetGameMode
    
    var ruleNameColor: Color {
        var color = Color("RegularScheduleRuleColor")
        switch gameMode {
        case .gachi:
            color = Color("RankedScheduleRuleColor")
        case .league:
            color = Color("LeagueScheduleRuleColor")
        case .regular:
            color = Color("RegularScheduleRuleColor")
        }
        return color
    }
    
    var vSpacing: CGFloat {
        var vSpacing: CGFloat = 11
        if entry.size == .size360 {
            vSpacing = 13
        } else if entry.size == .size338 {
            vSpacing = 11.5
        } else if entry.size == .size322 {
            vSpacing = 8.5
        } else if entry.size == .size291 {
            vSpacing = 9
        }
        return vSpacing
    }
    
    var titleAndStageSpacing: CGFloat {
        var titleAndStageSpacing: CGFloat = 8
        if entry.size == .size360 {
            titleAndStageSpacing = 9
        }
        return titleAndStageSpacing
    }
    
    var backgroundName: String {
        switch gameMode {
        case .regular:
            return "RegularBattleBackground"
        case .gachi:
            return "RankedBattleBackground"
        case .league:
            return "LeagueBattleBackground"
        }
    }
    
    var body: some View {
        if entry.schedules != nil {
            makeContent()
                .background(
                    Image(backgroundName)
                        .aspectRatio(1, contentMode: .fill)
                        .unredacted()
                )
                .padding(16)
        } else {
            makeContent()
                .background(
                    Image(backgroundName)
                        .aspectRatio(1, contentMode: .fill)
                        .unredacted()
                )
                .padding(16)
                .redacted(reason: .placeholder)
        }
    }
    
    private let scheduleTimeFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    func makeContent() -> some View {
        VStack(spacing: vSpacing) {
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
                        stageId: entry.schedules?[0].stageA.id ?? "0",
                        stageName: entry.schedules?[0].stageA.name ?? "            "
                    )
                }
                
                VStack(spacing: titleAndStageSpacing) {
                    HStack {
                        Spacer()
                        
                        Text("\(entry.schedules?[0].rule.name ?? "      ")")
                            .sp1Font(size: 14, color: ruleNameColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 0, x: 1, y: 1)
                    }
                    
                    makeStageImage(
                        stageId: entry.schedules?[0].stageB.id ?? "0",
                        stageName: entry.schedules?[0].stageB.name ?? "            "
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
                        Text("Next")
                            .sp1Font(size: 14)
                            .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                            .unredacted()
                        
                        Spacer()
                    }
                    
                    makeStageImage(
                        stageId: entry.schedules?[1].stageA.id ?? "0",
                        stageName: entry.schedules?[1].stageA.name ?? "            "
                    )
                }
                
                VStack(spacing: titleAndStageSpacing) {
                    HStack {
                        Spacer()
                        
                        Text("\(entry.schedules?[1].rule.name ?? "      ")")
                            .sp1Font(size: 14, color: ruleNameColor)
                            .shadow(color: Color.black.opacity(0.2), radius: 0, x: 1, y: 1)
                    }
                    
                    makeStageImage(
                        stageId: entry.schedules?[1].stageB.id ?? "0",
                        stageName: entry.schedules?[1].stageB.name ?? "            "
                    )
                }
            }
        }
    }
    
    func makeStageImage(stageId: String, stageName: String) -> some View {
        var borderColor = Color("RegularScheduleStageBorderColor")
        switch gameMode {
        case .gachi:
            borderColor = Color("RankedScheduleStageBorderColor")
        case .league:
            borderColor = Color("LeagueScheduleStageBorderColor")
        case .regular:
            borderColor = Color("RegularScheduleStageBorderColor")
        }
        
        return Image("stage-\(stageId)")
            .resizable()
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
            .overlay(Text("\(stageName)").sp2Font(), alignment: .center)
            .cornerRadius(6)
            .clipped()
    }
}
