//
//  PopupModifier.swift
//  imink
//
//  Created by Jone Wang on 2021/4/29.
//

import SwiftUI

struct Popup<T: View>: ViewModifier {
    let popup: T
    var isPresented: Bool
    let onDismiss: () -> Void
    
    @State private var offsetY: CGFloat = 0
    
    init(isPresented: Bool, onDismiss: @escaping () -> Void, @ViewBuilder content: () -> T) {
        self.isPresented = isPresented
        self.popup = content()
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    background()
                    popupContent()
                }
            )
    }
    
    @ViewBuilder private func popupContent() -> some View {
        GeometryReader { geometry in
            if isPresented {
                popup
                    .animation(.easeOut)
                    .transition(.offset(x: 0, y: geometry.size.height))
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                    .offset(x: 0, y: offsetY)
            }
        }
    }
    
    @ViewBuilder private func background() -> some View {
        if isPresented {
            Rectangle()
                .foregroundColor(Color.black.opacity(0.5))
                .transition(.opacity)
                .onTapGesture {
                    onDismiss()
                }
        }
    }
}
