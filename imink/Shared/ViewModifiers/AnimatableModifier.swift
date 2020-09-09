//
//  AnimatableModifier.swift
//  imink
//
//  Created by Jone Wang on 2020/9/3.
//

import Foundation
import SwiftUI

struct SwimmingAnimationModifier: AnimatableModifier {
    var speed: Double = 1
    
    @State private var inkfishRetract = true
    
    private func swim() {
        let kickTime = 0.7 / speed
        let retractTime = 1.5 / speed
        
        let delay = inkfishRetract ? retractTime : kickTime

        withAnimation(
            self.inkfishRetract ?
                Animation.easeOutQuad(duration: retractTime) :
                Animation.easeOutCirc(duration: kickTime)
        ) {
            self.inkfishRetract.toggle()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            swim()
        }
    }

    func body(content: Content) -> some View {
        content
            .scaleEffect(
                inkfishRetract ?
                    .init(width: 0.9, height: 1.2) :
                    .init(width: 1.1, height: 0.9)
                    
            )
            .onAppear {
                swim()
            }
    }
}

struct AnimatableModifier_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Image("SquidLoading")
                .modifier(SwimmingAnimationModifier())
        }
        .frame(width: 300, height: 300)
    }
}
