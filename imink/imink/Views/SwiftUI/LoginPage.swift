//
//  LoginPage.swift
//  imink
//
//  Created by Jone Wang on 2020/9/27.
//

import SwiftUI

struct LoginPage: View {
    
    enum LoginMethod {
        case token
    }
        
    @StateObject var launchPageViewModel: LoginViewModel
    
    @State private var selectedLoginMethod: LoginMethod?
    
    var body: some View {
        ZStack {
            VStack {
                if let _ = selectedLoginMethod {
                    VStack {
                        Text("sign_in_with_token_title")
                            .font(.title)
                            .padding()
                            .cornerRadius(10)
                        
                        Spacer()
                        
                        VStack {
                            Text("sign_in_with_token_faq_1")
                                .font(.footnote)
                            
                            Link("sign_in_with_token_faq_2", destination: URL(string: "tg://resolve?domain=Sp2BattleBot")!)
                            
                            Text("sign_in_with_token_faq_3")
                                .font(.footnote)
                        }
                        
                        TextField("Client-Token", text: $launchPageViewModel.clientToken)
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
                                    self.selectedLoginMethod = nil
                                }
                            }) {
                                Text("button_back_title")
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                    .padding(5)
                                    .background(Color.secondary)
                                    .cornerRadius(10)
                            }
                            .padding()
                            
                            Button(action: {
                                launchPageViewModel.login()
                            }) {
                                Text("button_sign_in_title")
                                    .foregroundColor(.white)
                                    .frame(width: 100)
                                    .padding(5)
                                    .background(Color.accentColor)
                                    .cornerRadius(10)
                            }
                            .disabled(launchPageViewModel.clientToken == "")
                            .opacity(launchPageViewModel.clientToken == "" ? 0.5 : 1)
                            .padding()
                        }
                    }
                    .padding()
                } else {
                    VStack {
                        Text("sign_in_title")
                            .font(.title)
                            .padding()
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                self.selectedLoginMethod = .token
                            }
                        }) {
                            Text("sign_in_with_token_title")
                                .foregroundColor(.white)
                                .frame(width: 250)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(10)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            
            if launchPageViewModel.status == .loading {
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
