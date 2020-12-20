//
//  BubbleView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/29.
//

import SwiftUI
import WidgetKit

struct GrayscaleTextureView: View {
    
    let textureName: String
    let foregroundColor: Color
    let backgroundColor: Color
    
    var body: some View {
        Rectangle().mask(
            Image(textureName)
                .resizable(resizingMode: .tile)
                .luminanceToAlpha()
        )
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .unredacted()
    }
}

extension GrayscaleTextureView {
    
    static let salmonRunBubble = GrayscaleTextureView(
        textureName: "BubbleTexture",
        foregroundColor: Color("SalmonRunBubbleForegroundColor"),
        backgroundColor: Color("SalmonRunBubbleBackgroundColor"))
    
    static let regularStreak = GrayscaleTextureView(
        textureName: "StreakTexture",
        foregroundColor: Color("RegularStreakForegroundColor"),
        backgroundColor: Color("RegularStreakBackgroundColor"))
    
    static let rankStreak = GrayscaleTextureView(
        textureName: "StreakTexture",
        foregroundColor: Color("RankStreakForegroundColor"),
        backgroundColor: Color("RankStreakBackgroundColor"))
    
    static let leagueStreak = GrayscaleTextureView(
        textureName: "StreakTexture",
        foregroundColor: Color("LeagueStreakForegroundColor"),
        backgroundColor: Color("LeagueStreakBackgroundColor"))
    
    static let topbarStreak = GrayscaleTextureView(
        textureName: "StreakTexture",
        foregroundColor: Color("TopbarStreakForegroundColor"),
        backgroundColor: Color("TopbarStreakBackgroundColor"))
    
    static let topbarBubble = GrayscaleTextureView(
        textureName: "BubbleTexture",
        foregroundColor: Color("TopbarStreakForegroundColor"),
        backgroundColor: Color("TopbarStreakBackgroundColor"))
}

struct GrayscaleTextureView_Previews: PreviewProvider {
    static var previews: some View {
        GrayscaleTextureView(
            textureName: "BubbleTexture",
            foregroundColor: Color("SalmonRunBubbleForegroundColor"),
            backgroundColor: Color("SalmonRunBubbleBackgroundColor"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

