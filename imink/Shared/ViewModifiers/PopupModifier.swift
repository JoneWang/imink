//
//  PopupModifier.swift
//  imink
//
//  Created by Jone Wang on 2021/4/29.
//

import SwiftUI

extension View {
    func popup(isPresented: Bool, onDismiss: @escaping () -> Void, @ViewBuilder content: () -> Content) -> some View {
        self.modifier(
            Popup(isPresented: isPresented,
                  onDismiss: onDismiss,
                  content: content)
        )
    }
}

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
                    .animation(.spring(response: 0.55, dampingFraction: 0.825, blendDuration: 0)) // 1.
                    .transition(.offset(x: 0, y: geometry.size.height + 100))
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                    .offset(x: 0, y: offsetY)
//                    .gesture(
//                        DragGesture()
//                            .onChanged({ gesture in
//                                let moveY = gesture.translation.height
//                                print("moveY: \(moveY)")
//                                if moveY < 0 {
//                                    if moveY < -300 {
//                                        return
//                                    }
//
//                                    let r: CGFloat = 200
//                                    let x = abs(moveY) / r
//                                    let y = -x*x + 2*x;
//
//                                    offsetY = y * (1 - r) * -1
//                                    print(y * r)
////                                    let y = (200 - moveY) / 200
//                                    print("y: \(y)")
////                                    print("y: \(gesture.translation.height - y * 200)")
////                                    if y < 0 {
////
////                                        offsetY = -y
////                                    }
//                                } else {
//                                    offsetY = moveY
//                                }
//                            })
//                            .onEnded({ _ in
//                                if offsetY > 120 {
//                                    onDismiss()
//                                    offsetY = 0
//                                } else {
//                                    offsetY = 0
//                                }
//                            })
//                    )
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
