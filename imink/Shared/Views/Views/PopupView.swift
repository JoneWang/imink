//
//  PopupView.swift
//  imink-swiftui (iOS)
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI

struct SPPopupView<Content>: View where Content: View {
    let content: Content
    let color: Color
    var body: some View {
        content
            .background(
                ZStack {
                    Image("Bubble")
                        .resizable(resizingMode: .tile)
                    color
                        .blendMode(.sourceAtop)
                }
            )
            .cornerRadius(50)
    }
}

struct PopupView_Previews: PreviewProvider {
    static var previews: some View {
        SPPopupView(
            content: Text("").frame(width: 400, height: 300, alignment: .center),
            color: Color("ClientTokenInputBackgroundColor")
        )
    }
}
