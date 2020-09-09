//
//  AutoPlayerAnimation.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import SwiftUI

extension View {
    func animate(
        _ animation: Animation = Animation.easeInOut(duration: 1),
        _ action: @escaping () -> Void
    ) -> some View {
        return onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}

extension View {
    func animateForever(
        _ animation: Animation = Animation.easeInOut(duration: 1),
        autoreverses: Bool = false, _ action: @escaping () -> Void
    ) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)
        
        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}
