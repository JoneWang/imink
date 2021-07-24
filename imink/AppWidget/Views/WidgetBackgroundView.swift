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
    @Environment(\.widgetSize) var widgetSize: CGSize
    @Environment(\.widgetFamily) var widgetFamily
    
    // Scaling by 360 width
    private let widgetBaseWidth: CGFloat = 360
    
    let texture: GrayscaleTextureView

    var body: some View {
        Rectangle()
            .overlay(
                texture
                    .frame(width: widgetBaseWidth, height: widgetSize.height * (widgetBaseWidth / widgetSize.width))
                    .scaleEffect(widgetSize.width / widgetBaseWidth, anchor: .top),
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
        texture: .bubble,
        foregroundColor: Color("TopbarStreakForegroundColor"),
        backgroundColor: Color("TopbarStreakBackgroundColor"))
}

struct WidgetBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetBackgroundView(texture: .salmonRunBubble)
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDevice("iPhone 12 Pro Max")
    }
}
