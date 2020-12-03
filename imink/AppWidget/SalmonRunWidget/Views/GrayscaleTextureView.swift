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
}

struct GrayscaleTextureView_Previews: PreviewProvider {
    static var previews: some View {
        GrayscaleTextureView.salmonRunBubble
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

