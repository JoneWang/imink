//
//  WidgetBackgroundView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/12/6.
//

import SwiftUI
import WidgetKit
import InkCore

struct WidgetBackgroundView: View {
    
    // Scaling by 360 width
    private var widgetBaseSize: CGSize {
        WidgetSize.size360.cgSize(with: widgetFamily)
    }
    
    let texture: GrayscaleTextureView
    
    let widgetFamily: WidgetFamily
    let widgetSize: WidgetSize

    var body: some View {
        let size = widgetSize.cgSize(with: widgetFamily)
        Rectangle()
            .overlay(
                texture
                    .frame(width: widgetBaseSize.width, height: size.height * (widgetBaseSize.width / size.width))
                    .scaleEffect(size.width / widgetBaseSize.width, anchor: .top),
                alignment: .top
            )
    }
}

extension GrayscaleTextureView {
    
    static let salmonRunBubble = GrayscaleTextureView(
        texture: .bubble,
        foregroundColor: Color("SalmonRunBubbleForegroundColor"),
        backgroundColor: Color("SalmonRunBubbleBackgroundColor"))
    
    static let regularStreak = GrayscaleTextureView(
        texture: .streak,
        foregroundColor: Color("RegularStreakForegroundColor"),
        backgroundColor: Color("RegularStreakBackgroundColor"))
    
    static let rankStreak = GrayscaleTextureView(
        texture: .streak,
        foregroundColor: Color("RankStreakForegroundColor"),
        backgroundColor: Color("RankStreakBackgroundColor"))
    
    static let leagueStreak = GrayscaleTextureView(
        texture: .streak,
        foregroundColor: Color("LeagueStreakForegroundColor"),
        backgroundColor: Color("LeagueStreakBackgroundColor"))
    
    static let topbarStreak = GrayscaleTextureView(
        texture: .streak,
        foregroundColor: Color("TopbarStreakForegroundColor"),
        backgroundColor: Color("TopbarStreakBackgroundColor"))
    
    static let topbarBubble = GrayscaleTextureView(
        texture: .streak,
        foregroundColor: Color("TopbarStreakForegroundColor"),
        backgroundColor: Color("TopbarStreakBackgroundColor"))
}

struct WidgetBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetBackgroundView(texture: .salmonRunBubble, widgetFamily: .systemMedium, widgetSize: .size322)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
