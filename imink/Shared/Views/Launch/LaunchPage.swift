//
//  Launch.swift
//  imink
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI

struct LaunchPage: View {
    @Binding var clientToken: String?
    @Binding var loginUser: User?
    
    @StateObject private var launchPageViewModel = LaunchPageViewModel()
    @State private var status: LaunchPageViewModel.Status? = .needToken

    var body: some View {
        let contentView = ZStack {
            // Background
            Rectangle().overlay(
                Image("LaunchBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            )

            if status == .needToken {
                // Client Token login
                ClientTokenLoginPopupView(clientToken: $launchPageViewModel.inputClientToken) {
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
            }
        }
        .onReceive(launchPageViewModel.$loginUser) { user in
            self.loginUser = user
        }
        .onReceive(launchPageViewModel.$clientToken) { clientToken in
            self.clientToken = clientToken
        }
        
        
        #if os(iOS)
        contentView
            .edgesIgnoringSafeArea(.all)
        #else
        contentView
        #endif
    }
}

//struct Launch_Previews: PreviewProvider {
//    static var previews: some View {
//        StatefulPreviewWrapper(nil as! User?) {
//            LaunchPage(loginUser: $0)
//                .frame(width: 1000, height: 800)
//        }
//    }
//}
