//
//  LoadingPopupView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/3.
//

import SwiftUI

struct LoadingPopupView: View {
    var body: some View {
        SPPopupView(
            content: VStack {
                Image("SquidLoading")
                    .modifier(SwimmingAnimationModifier())
                
                Text("popup_loading_title")
                    .sp2Font(size: 30)
            }.frame(width: 400, height: 250),
            color: AppColor.spPurple,
            backgroundAnimated: true
        )
    }
}

struct LoadingPopupView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingPopupView()
    }
}
