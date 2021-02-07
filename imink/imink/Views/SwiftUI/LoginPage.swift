//
//  LoginPage.swift
//  imink
//
//  Created by Jone Wang on 2020/9/27.
//

import SwiftUI

struct LoginPage: View {
    @StateObject var loginViewModel: LoginViewModel
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text("Welcome to imink!")
                        .font(.title)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        loginViewModel.useNintendoAccount = true
                    }) {
                        Text("Sign in with Nintendo Account")
                            .foregroundColor(.white)
                            .frame(width: 250)
                            .padding()
                            .background(AppColor.nintendoRedColor)
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                }
                .padding()
            }
            
            if loginViewModel.status == .loading {
                Rectangle()
                    .foregroundColor(Color.primary.opacity(0.8))
                    .colorInvert()
                    .overlay(VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    })
            }
        }
        .sheet(isPresented: $loginViewModel.useNintendoAccount) {
            NintendoAccountLoginPage(viewModel: loginViewModel)
        }
        .frame(width: 400, height: 250)
    }
}

//struct LoginPage_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginPage {}
//            .previewLayout(.sizeThatFits)
//        LoginPage {}
//            .preferredColorScheme(.dark)
//            .previewLayout(.sizeThatFits)
//    }
//}
