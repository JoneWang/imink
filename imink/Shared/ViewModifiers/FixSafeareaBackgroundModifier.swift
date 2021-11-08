//
//  FixSafeareaBackgroundModifier.swift
//  imink
//
//  Created by Jone Wang on 2021/10/1.
//

import SwiftUI

extension View {
    func fixSafeareaBackground() -> some View {
        self.modifier(FixSafeareaBackgroundModifier())
    }
}

struct FixSafeareaBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // FIXME: Fix navigationBar and tabBar background is white.
            Rectangle()
                .fill(AppColor.listBackgroundColor)
                .edgesIgnoringSafeArea(.all)
            
            content
        }
    }
}
