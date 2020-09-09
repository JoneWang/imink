//
//  ClientTokenInputView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI

struct ClientTokenLoginPopupView: View {
    @Binding var clientToken: String
    let okAction: () -> Void
    
    private enum TokenState {
        case waitPasting
        case error
        case ok
    }

    @State private var tokenState = TokenState.waitPasting
    
    var body: some View {
        let contents: Array<(LocalizedStringKey, CGFloat)> = [
            ("token_login_title", 40),
            ("token_login_content_1", 20),
            ("token_login_content_2", 15),
            ("token_login_content_3", 20),
            ("token_login_content_4", 20),
        ]
        return SPPopupView(
            content: VStack {
                ForEach(contents.indices) { i in
                    Text(contents[i].0)
                        .sp2Font(size: contents[i].1, lineLimit: 2)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                }
                
                if tokenState == .ok {
                    SPButton(title: clientToken,
                             color: .white,
                             titleColor: Color.black,
                             titleFontSize: 20,
                             width: 600) {
                        checkClientToken(token: PasteBoard.getString())
                    }.padding(.top, 10)
                } else {
                    SPButton(tokenState == .waitPasting ?
                                LocalizedStringKey("token_login_paste_button") :
                                LocalizedStringKey("token_login_error"),
                             color: .white,
                             titleColor: tokenState == .error ?
                                AppColor.spRed.opacity(0.8) :
                                .black,
                             titleFontSize: 20,
                             width: 600) {
                        checkClientToken(token: PasteBoard.getString())
                    }.padding(.top, 10)
                }
                
                SPButton("token_login_ok_button", width: 200) {
                    if tokenState == .ok { okAction() }
                }.padding(.top, 10)
            }
            .frame(width: 700, height: 550),
            color: AppColor.spGreen
        )
    }
    
    func checkClientToken(token: String?) {
        guard let token = token, token.count == 32 else {
            tokenState = .error
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                tokenState = .waitPasting
            }
            return
        }
        
        tokenState = .ok
        clientToken = token
    }
}

struct ClientTokenInputView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper("") {
            ClientTokenLoginPopupView(clientToken: $0) { }
        }
    }
}
