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

struct GrayscaleTextureView_Previews: PreviewProvider {
    static var previews: some View {
        GrayscaleTextureView(
            textureName: "BubbleTexture",
            foregroundColor: Color("SalmonRunBubbleForegroundColor"),
            backgroundColor: Color("SalmonRunBubbleBackgroundColor"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

