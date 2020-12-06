//
//  BattleScheduleLargeWidgetEntryView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/10/21.
//

import Foundation
import WidgetKit
import SwiftUI

struct BattleScheduleLargeWidgetEntryView : View {
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
    
    var topBarSpacing: CGFloat {
        var spacing: CGFloat = 16
        if entry.size == .size360 {
            spacing = 17
        } else if entry.size == .size338 {
            spacing = 15
        } else if entry.size == .size322 {
            spacing = 14
        } else if entry.size == .size291 {
            spacing = 11
        }
        return spacing
    }
    
    var vSpacing: CGFloat {
        var vSpacing: CGFloat = 18
        if entry.size == .size338 {
            vSpacing = 17
        } else if entry.size == .size322 {
            vSpacing = 13
        } else if entry.size == .size291 {
            vSpacing = 12
        }
        return vSpacing
    }
    
    var titleAndStageSpacing: CGFloat {
        var titleAndStageSpacing: CGFloat = 8
        if entry.size == .size322 {
            titleAndStageSpacing = 7
        } else if entry.size == .size291 {
            titleAndStageSpacing = 6
        }
        return titleAndStageSpacing
    }
    
    var stageImageAndNameSpcaing: CGFloat {
        var spcaing: CGFloat = 8
        if entry.size == .size291 {
            spcaing = 6
        }
        return spcaing
    }
    
    var stagePadding: CGFloat {
        var padding: CGFloat = 10
        if entry.size == .size360 {
            padding = 11
        } else if entry.size == .size291 {
            padding = 8
        }
        return padding
    }
    
    var stageSpacing: CGFloat {
        var spacing: CGFloat = 10
        if entry.size == .size360 {
            spacing = 11
        } else if entry.size == .size291 {
            spacing = 8
        }
        return spacing
    }
    
    var stageNameFontSize: CGFloat {
        var size: CGFloat = 12
        if entry.size == .size291 {
            size = 11
        }
        return size
    }
    
    var stageNameWidth: CGFloat {
        var size: CGFloat = 65.5
        if entry.size == .size348 {
            size = 67
        } else if entry.size == .size329 {
            size = 65
        } else if entry.size == .size322 ||
                    entry.size == .size338 {
            size = 66
        } else if entry.size == .size291 {
            size = 55
        }
        return size
    }
    
    var background: some View {
        let bg = WidgetBackground(family: entry.family, widgetSize: entry.size)
        switch gameMode {
        case .regular:
            return bg.regularStreak
        case .gachi:
            return bg.rankStreak
        case .league:
            return bg.leagueStreak
        }
    }
    
    var titleIconName: String {
        switch gameMode {
        case .regular:
            return "RegularBattleMono"
        case .gachi:
            return "RankedBattleMono"
        case .league:
            return "LeagueBattleMono"
        }
    }
    
    var topBarHeight: CGFloat {
        var height: CGFloat = 49
        if entry.size == .size291 {
            height = 47
        }
        return height
    }
    
    var stageNameLineSpacing: CGFloat {
        var lineSpacing: CGFloat = 3.3
        if entry.size == .size291 {
            lineSpacing = 3.025
        }
        return lineSpacing
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
            
            VStack(spacing: topBarSpacing) {
                ZStack {
                    WidgetBackground(family: entry.family, widgetSize: entry.size).topbarStreak
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Image(titleIconName)
                        Text(gameMode.name)
                            .sp1Font(size: 17)
                        Spacer()
                    }
                    .offset(x: 0, y: 2)
                }
                .frame(height: topBarHeight)
                .clipped()
                .unredacted()
                
                VStack(spacing: vSpacing) {
                    ForEach(0..<3) { index in
                        let schedule: Schedules.Schedule? = entry.schedules?[index]
                        let titles: [LocalizedStringKey] = [
                            "Now",
                            schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat)-\(schedule!.endTime, formatter: scheduleTimeFormat)" : "     ",
                            schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat)-\(schedule!.endTime, formatter: scheduleTimeFormat)" : "     "]
                        
                        VStack(spacing: titleAndStageSpacing) {
                            HStack {
                                Text(titles[index])
                                    .sp1Font(size: 14)
                                    .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                    .unredacted()
                                
                                Spacer()
                                
                                Text(schedule?.rule.name.localizedKey ?? "      ")
                                    .sp1Font(size: 14, color: ruleNameColor)
                                    .shadow(color: Color.black.opacity(0.2), radius: 0, x: 1, y: 1)
                            }
                            .padding(.top, 0)
                            
                            HStack(spacing: stageSpacing) {
                                HStack(spacing: stageImageAndNameSpcaing) {
                                    makeStageImage(
                                        stageId: schedule?.stageA.id ?? "0"
                                    )
                                    .padding([.leading, .top, .bottom], stagePadding)
                                    
                                    Text(schedule?.stageA.nameLocalizedStringKey ?? "      \n      ")
                                        .sp2Font(size: stageNameFontSize, lineLimit: 2)
                                        .lineSpacing(stageNameLineSpacing)
                                        .multilineTextAlignment(.leading)
                                        .minimumScaleFactor(0.7)
                                        .frame(minWidth: stageNameWidth, maxWidth: stageNameWidth, alignment: .leading)
                                }
                                
                                HStack(spacing: stageImageAndNameSpcaing) {
                                    makeStageImage(
                                        stageId: schedule?.stageB.id ?? "0"
                                    )
                                    .padding([.top, .bottom], stagePadding)
                                    
                                    Text(schedule?.stageB.nameLocalizedStringKey ?? "      \n      ")
                                        .sp2Font(size: stageNameFontSize, lineLimit: 2)
                                        .lineSpacing(stageNameLineSpacing)
                                        .multilineTextAlignment(.leading)
                                        .minimumScaleFactor(0.7)
                                        .frame(minWidth: stageNameWidth, maxWidth: stageNameWidth, alignment: .leading)
                                        .padding(.trailing, stagePadding)
                                }
                            }
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding([.leading, .trailing, .bottom], 16)
                .padding(.top, 0)
            }
        }
    }
    
    func makeStageImage(stageId: String) -> some View {
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
            //            .aspectRatio(contentMode: .fill)
            .frame(minHeight: 0, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(borderColor.opacity(0.4), lineWidth: 1)
            )
            .cornerRadius(6)
            .clipped()
    }
}

private extension Stage {
    
    var nameLocalizedStringKey: LocalizedStringKey {
        "\(name)_multi-line".localizedKey
    }
    
}

extension BattleScheduleWidgetGameMode {
    
    var name: LocalizedStringKey {
        switch self {
        case .regular:
            return "Regular Battle"
        case .gachi:
            return "Ranked Battle"
        case .league:
            return "League Battle"
        }
    }
    
}
