//
//  NotchBranding.swift
//  imink
//
//  Created by Ryan on 2021/7/19.
//

import SwiftUI

struct NotchBranding: View {
    
    @State var isShow = true
    @State var delayedDisplayInProgress = false
    
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
                    .transition(.fade(duration: 0.1))
            }
        }
        .onAppear {
            isShow = isAllScreen
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIScene.willDeactivateNotification)) { _ in
            isShow = false
            delayedDisplayInProgress = false
        }
        .onReceive(NotificationCenter
                    .default
                    .publisher(for: UIScene.didActivateNotification)) { _ in
            if isAllScreen {
                delayedDisplayInProgress = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isShow = delayedDisplayInProgress
                }
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
