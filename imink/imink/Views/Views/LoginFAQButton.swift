//
//  LoginFAQButton.swift
//  imink
//
//  Created by Jone Wang on 2021/7/21.
//

import SwiftUI

struct LoginFAQButton: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle")
            
            Text("登录遇到问题？")
                .font(.system(size: 14))
        }
        .foregroundColor(.black)
        .padding(.init(top: 6, leading: 8, bottom: 6, trailing: 5))
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(radius: 0.5)
    }
}

struct LoginFAQButton_Previews: PreviewProvider {
    static var previews: some View {
        LoginFAQButton()
    }
}
