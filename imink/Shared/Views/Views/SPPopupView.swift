//
//  PopupView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI

struct SPPopupView<Content>: View where Content: View {
    let content: Content
    let color: Color
    var backgroundAnimated = false
    var backgroundAnimationSpeed = 1.0
    
    @State private var animationBackgroundOffset = CGSize(
        width: 0,
        height: -AppTheme.defaultTextureSize.height
    )
    
    var body: some View {
        content
            .background(
                ZStack(alignment: .center) {
                    if backgroundAnimated {
                        GeometryReader { geo in
                            makeAnimationBackground(geo: geo)
                        }
                    } else {
                        Image("Bubble").resizable(resizingMode: .tile)
                    }

                    color
                        .opacity(0.78)
                        .blendMode(.sourceAtop)
                }
            )
            .cornerRadius(50)
            .shadow(radius: 20)
    }
    
    func makeAnimationBackground(geo: GeometryProxy) -> some View {
        let textureSize = AppTheme.defaultTextureSize
        return Image("Bubble")
            .resizable(resizingMode: .tile)
            .frame(
                width: geo.size.width + textureSize.width,
                height: geo.size.height + textureSize.height,
                alignment: .bottom
            )
            .offset(animationBackgroundOffset)
            .animate(
                Animation
                    .linear(duration: 20 / backgroundAnimationSpeed)
                    .repeatForever(autoreverses: false)
            ) {
                self.animationBackgroundOffset = CGSize(
                    width: -textureSize.width,
                    height: 0
                )
            }
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        SPPopupView(
            content: Text("").frame(width: 400, height: 300),
            color: AppColor.spGreen,
            backgroundAnimated: true
        )
    }
}
