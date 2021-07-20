//
//  NotchBranding.swift
//  imink
//
//  Created by Ryan on 2021/7/19.
//

import SwiftUI

struct NotchBranding: View {
    
    @State var isShow = true
    
    var isAllScreen: Bool {
        UIApplication.shared.windows.first!.safeAreaInsets.top > 20
    }
    
    var body: some View {
        Group {
            if isShow {
                Text("imink")
                    .font(.system(size: 13))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .padding(.init(top: 1, leading: 9, bottom: 1, trailing: 8))
                    .background(Color.systemGray5)
                    .continuousCornerRadius(10)
                    .padding(.top, 12)
                    .edgesIgnoringSafeArea(.top)
                    .animation(.none)
            }
        }
        .onAppear {
            isShow = isAllScreen
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIScene.willDeactivateNotification)) { _ in
            isShow = false
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            if isAllScreen {
                isShow = true
            }
        }
    }
}

struct NotchBranding_Previews: PreviewProvider {
    static var previews: some View {
        Rectangle()
            .foregroundColor(.white)
            .ignoresSafeArea()
            .overlay(NotchBranding(), alignment: .top)
            .previewDevice("iPhone 11")
    }
}
