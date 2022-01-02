//
//  PopoverModifier.swift
//  imink
//
//  Created by Jone Wang on 2022/1/2.
//

import SwiftUI
import Popovers

extension PopoverTemplates {
    public struct Standard: View {
        
        @State var shrunk = true
        
        public let content: AnyView
        
        public init<T: View>(@ViewBuilder content: () -> T) {
            self.content = AnyView(content())
        }
        
        public var body: some View {
            content
                .background(AppColor.listItemBackgroundColor)
                .cornerRadius(12)
                .popoverContainerShadow()
                .scaleEffect(
                    shrunk ? 0.2 : 1,
                    anchor: .topTrailing
                )
                .onAppear {
                    withAnimation(
                        .spring(
                            response: 0.4,
                            dampingFraction: 0.8,
                            blendDuration: 1
                        )
                    ) {
                        shrunk = false
                    }
                }
        }
    }
}
