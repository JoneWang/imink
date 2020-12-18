//
//  WidgetBackgroundView.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2020/12/6.
//

import SwiftUI
import WidgetKit

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

struct WidgetBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetBackgroundView(texture: .salmonRunBubble, widgetFamily: .systemMedium, widgetSize: .size322)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
