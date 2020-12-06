//
//  WidgetBackgroundView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/12/6.
//

import SwiftUI
import WidgetKit

struct WidgetBackground {
    let family: WidgetFamily
    let widgetSize: WidgetSize
}

extension WidgetBackground {
    
    var salmonRunBubble: WidgetBackgroundView {
        WidgetBackgroundView(
            textureName: "BubbleTexture",
            foregroundColor: Color("SalmonRunBubbleForegroundColor"),
            backgroundColor: Color("SalmonRunBubbleBackgroundColor"),
            widgetFamily: family, widgetSize: widgetSize)
    }
    
    var regularStreak: WidgetBackgroundView {
        WidgetBackgroundView(
            textureName: "StreakTexture",
            foregroundColor: Color("RegularStreakForegroundColor"),
            backgroundColor: Color("RegularStreakBackgroundColor"),
            widgetFamily: family, widgetSize: widgetSize)
    }
    
    var rankStreak: WidgetBackgroundView {
        WidgetBackgroundView(
            textureName: "StreakTexture",
            foregroundColor: Color("RankStreakForegroundColor"),
            backgroundColor: Color("RankStreakBackgroundColor"),
            widgetFamily: family, widgetSize: widgetSize)
    }
    
    var leagueStreak: WidgetBackgroundView {
        WidgetBackgroundView(
            textureName: "StreakTexture",
            foregroundColor: Color("LeagueStreakForegroundColor"),
            backgroundColor: Color("LeagueStreakBackgroundColor"),
            widgetFamily: family, widgetSize: widgetSize)
    }
    
    var topbarStreak: WidgetBackgroundView {
        WidgetBackgroundView(
            textureName: "StreakTexture",
            foregroundColor: Color("TopbarStreakForegroundColor"),
            backgroundColor: Color("TopbarStreakBackgroundColor"),
            widgetFamily: family, widgetSize: widgetSize)
    }
    
    var topbarBubble: WidgetBackgroundView {
        WidgetBackgroundView(
            textureName: "BubbleTexture",
            foregroundColor: Color("TopbarStreakForegroundColor"),
            backgroundColor: Color("TopbarStreakBackgroundColor"),
            widgetFamily: family, widgetSize: widgetSize)
    }
    
}

struct WidgetBackgroundView: View {
    
    // Scaling by 360 width
    private var widgetBaseSize: CGSize {
        WidgetSize.size360.cgSize(with: widgetFamily)
    }
    
    let textureName: String
    let foregroundColor: Color
    let backgroundColor: Color
    
    let widgetFamily: WidgetFamily
    let widgetSize: WidgetSize

    var body: some View {
        let size = widgetSize.cgSize(with: widgetFamily)
        Rectangle()
            .overlay(
                GrayscaleTextureView(
                    textureName: textureName,
                    foregroundColor: foregroundColor,
                    backgroundColor: backgroundColor
                )
                .frame(width: widgetBaseSize.width, height: size.height * (widgetBaseSize.width / size.width))
                .scaleEffect(size.width / widgetBaseSize.width, anchor: .top),
                alignment: .top
            )
            .unredacted()
    }
}

struct WidgetBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetBackgroundView(
            textureName: "BubbleTexture",
            foregroundColor: Color("SalmonRunBubbleForegroundColor"),
            backgroundColor: Color("SalmonRunBubbleBackgroundColor"),
            widgetFamily: .systemMedium,
            widgetSize: .size322
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
