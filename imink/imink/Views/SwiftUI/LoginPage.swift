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
                if loginViewModel.useClientToken {
                    VStack {
                        Text("Sign in with Telegram Bot")
                            .font(.title)
                            .padding()
                            .cornerRadius(10)
                        
                        Spacer()
                        
                        VStack {
                            Text("Sending /clienttoken to ")
                                .font(.footnote)
                            
                            Link("@Sp2BattleBot", destination: URL(string: "tg://resolve?domain=Sp2BattleBot")!)
                            
                            Text(" bot in Telegram to get Client-Token.")
                                .font(.footnote)
                        }
                        
                        TextField("Client Token", text: $loginViewModel.clientToken)
                            .multilineTextAlignment(.center)
                            .padding(2)
                            .frame(width: 280)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.secondary, lineWidth: 1)
                            )
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                withAnimation {
                                    self.loginViewModel.useNintendoAccount = false
                                }
                            }) {
                                Text("Back")
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                    .padding(5)
                                    .background(Color.secondary)
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                            Button(action: {
                                loginViewModel.login()
                            }) {
                                Text("Sign In")
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                    .padding(5)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                            }
                            .disabled(loginViewModel.clientToken == "")
                            .opacity(loginViewModel.clientToken == "" ? 0.5 : 1)
                            .padding()
                        }
                    }
                    .padding()
                } else {
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
                        .padding(.bottom)
                        
                        Button(action: {
                            withAnimation {
                                loginViewModel.useClientToken = true
                            }
                        }) {
                            Text("Sign in with Telegram Bot")
                                .foregroundColor(.white)
                                .frame(width: 250)
                                .padding()
                                .background(Color.accentColor)
                                .clipShape(Capsule())
                        }
                        .padding(.bottom)
                        
                    }
                    .padding()
                }
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
