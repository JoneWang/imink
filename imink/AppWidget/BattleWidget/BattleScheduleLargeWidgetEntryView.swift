//
//  BattleScheduleLargeWidgetEntryView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/10/21.
//

import Foundation
import WidgetKit
import SwiftUI
import InkCore

struct BattleScheduleLargeWidgetEntryView : View {
    @Environment(\.widgetSize) var widgetSize: CGSize
    
    var entry: BattleScheduleProvider.Entry
    var gameMode: BattleScheduleWidgetGameMode
    
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
            
            VStack(spacing: 0) {
                ZStack {
                    WidgetBackgroundView(texture: .topbarStreak)
                    
                    HStack(alignment: .center) {
                        Spacer()
                        Image(titleIconName)
                            .resizable()
                            .scaledToFit()
                            .frame(height:titleIconHeight, alignment: .center)
                        Text(gameMode.localizedName)
                            .sp1Font(size: topBarFontSize)
                            .padding(.bottom, topBarTitleOffset)
                        Spacer()
                    }
                    .offset(x: 0, y: 2)
                }
                .frame(height: topBarHeight)
                .clipped()
                .unredacted()
                
                VStack(spacing: 16) {
                    
                    ForEach(0..<3) { index in
                        let schedule: Schedules.Schedule? = entry.schedules?[index]
                        let titles: [LocalizedStringKey] = [
                            "Now",
                            schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat)-\(schedule!.endTime, formatter: scheduleTimeFormat)" : "     ",
                            schedule != nil ? "\(schedule!.startTime, formatter: scheduleTimeFormat)-\(schedule!.endTime, formatter: scheduleTimeFormat)" : "     "]
                        
                        VStack(spacing: titleAndStageSpacing) {
                            HStack {
                                Text(titles[index])
                                    .sp1Font(size: titleFontSize)
                                    .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                    .unredacted()
                                
                                Spacer()
                                
                                HStack(spacing: 6) {
                                    Text(schedule?.rule.localizedName ?? "      ")
                                        .sp1Font(size: titleFontSize)
                                        .shadow(color: Color.black.opacity(0.8), radius: 0, x: 1, y: 1)
                                    
                                    
                                    if let schedule = schedule, schedule.rule.key != .turfWar {
                                        Image(schedule.rule.imageName)
                                             .fixedSize()
                                             .frame(width:ruleIconWidth, height:ruleIconHeight, alignment: .center)
                                    }
                                }
                            }
                            .padding(.top, 0)
                            
                            HStack(spacing: stageSpacing) {
                                HStack(spacing: stageImageAndNameSpacing) {
                                    makeStageImage(
                                        stageId: schedule?.stageA.id ?? "0"
                                    )
                                    .padding([.leading, .top, .bottom], stagePadding)
                                    
                                    Text(schedule?.stageA.localizedMultilineName ?? "      \n      ")
                                        .sp2Font(size: stageNameFontSize, lineLimit: 2)
                                        .lineSpacing(stageNameLineSpacing)
                                        .multilineTextAlignment(.leading)
                                        .minimumScaleFactor(0.7)
                                        .frame(minWidth: stageNameWidth, maxWidth: stageNameWidth, alignment: .leading)
                                }
                                
                                HStack(spacing: stageImageAndNameSpacing) {
                                    makeStageImage(
                                        stageId: schedule?.stageB.id ?? "0"
                                    )
                                    .padding([.top, .bottom], stagePadding)
                                    
                                    Text(schedule?.stageB.localizedMultilineName ?? "      \n      ")
                                        .sp2Font(size: stageNameFontSize, lineLimit: 2)
                                        .lineSpacing(stageNameLineSpacing)
                                        .multilineTextAlignment(.leading)
                                        .minimumScaleFactor(0.7)
                                        .frame(minWidth: stageNameWidth, maxWidth: stageNameWidth, alignment: .leading)
                                        .padding(.trailing, stagePadding)
                                }
                            }
                            .background(Color.black.opacity(0.5))
                            .continuousCornerRadius(10)
                        }
                        .padding(.top, -1)
                    }
                }
                .padding([.top, .leading, .trailing, .bottom], 16)
            }
        }
    }
    
    func makeStageImage(stageId: String) -> some View {
        ImageView.stage(id: stageId)
            .frame(minHeight: 0, maxHeight: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(gameMode.stageBorderColor.opacity(0.4), lineWidth: 1)
            )
            .continuousCornerRadius(6)
            .clipped()
    }
}

extension BattleScheduleLargeWidgetEntryView {
    var topBarHeight: CGFloat { round(((widgetSize.width - 42) / 2) * 0.3035) }
    var topBarFontSize: CGFloat { widgetSize.width <= 306 ? 15 : 17 }
    var topBarTitleOffset: CGFloat { widgetSize.width == 364 || widgetSize.width == 338 ? 1 : 0 }
    var titleIconHeight: CGFloat { widgetSize.width <= 306 ? 19.5 : 22 }
    
    var titleFontSize: CGFloat { widgetSize.width <= 306 ? 13 : 14 }
    var ruleIconWidth: CGFloat { widgetSize.width <= 306 ? 19 : 20 }
    var ruleIconHeight: CGFloat { widgetSize.width <= 306 ? 13 : 14 }
    var titleAndStageSpacing: CGFloat { (widgetSize.width * 0.023).rounded() }
    var stagePadding: CGFloat { widgetSize.width <= 306 ? 8 : (widgetSize.width * 0.03).rounded() }
    var stageSpacing: CGFloat { widgetSize.width <= 306 ? 8 : (widgetSize.width * 0.03).rounded() }
    var stageImageAndNameSpacing: CGFloat { widgetSize.width <= 306 ? 6 : 8 }
    var stageNameFontSize: CGFloat { widgetSize.width <= 306 ? 11 : 12 }
    var stageNameLineSpacing: CGFloat { widgetSize.width <= 306 ? 3.025 : 3.3 }
    var stageNameWidth: CGFloat { widgetSize.width <= 306 ? 55 : 66 }
}

fileprivate extension Stage {
    
    var localizedMultilineName: String {
        "\(name)_multi-line".splatNet2Localized
    }
}

extension BattleScheduleWidgetGameMode {
    
    var localizedName: String {
        switch self {
        case .regular:
            return "Regular Battle".splatNet2Localized
        case .gachi:
            return "Ranked Battle".splatNet2Localized
        case .league:
            return "League Battle".splatNet2Localized
        }
    }
    
}

import SplatNet2API

struct BattleScheduleLargeWidgetEntryView_Previews: PreviewProvider {
    static let widgetFamily = WidgetFamily.systemLarge
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
