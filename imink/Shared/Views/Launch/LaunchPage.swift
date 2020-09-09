//
//  Launch.swift
//  imink
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI

struct LaunchPage: View {
    @Binding var isLogin: Bool

    @StateObject private var launchPageViewModel = LaunchPageViewModel()
    
    @State private var status: LaunchPageViewModel.Status? = .needToken
    
    var body: some View {
        ZStack {
            // Background
            Rectangle().overlay(
                Image("LaunchBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )

            if status == .needToken {
                // Client Token login
                ClientTokenLoginPopupView(clientToken: $launchPageViewModel.clientToken) {
                    launchPageViewModel.login()
                }
                .transition(.move(edge: .bottom))
            } else if status == .loading {
                // Loading
                LoadingPopupView()
                    .transition(.move(edge: .bottom))
            }
        }
        .onReceive(launchPageViewModel.$status) { value in
            withAnimation {
                self.status = value
                if value == .loginSuccess {
                    self.isLogin = true
                }
            }
        }
    }
}

struct Launch_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(false) {
            LaunchPage(isLogin: $0)
                .frame(width: 1000, height: 800)
        }
    }
}
