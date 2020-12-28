//
//  BubbleView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/11/29.
//

import SwiftUI
import WidgetKit

public struct GrayscaleTextureView: View {
    
    public enum Texture {
        case streak, bubble
    }
    
    let texture: Texture
    let foregroundColor: Color
    let backgroundColor: Color
    
    public init(texture: Texture, foregroundColor: Color, backgroundColor: Color) {
        self.texture = texture
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        Rectangle().mask(
            Image(texture.imageName, bundle: Bundle.inkCore)
                .resizable(resizingMode: .tile)
                .luminanceToAlpha()
        )
        .foregroundColor(foregroundColor)
        .background(backgroundColor)
        .unredacted()
    }
}

fileprivate extension GrayscaleTextureView.Texture {
    
    var imageName: String {
        switch self {
        case .streak:
            return "StreakTexture"
        case .bubble:
            return "BubbleTexture"
        }
    }
    
}

struct GrayscaleTextureView_Previews: PreviewProvider {
    static var previews: some View {
        GrayscaleTextureView(
            texture: .bubble,
            foregroundColor: Color("SalmonRunBubbleForegroundColor"),
            backgroundColor: Color("SalmonRunBubbleBackgroundColor"))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

