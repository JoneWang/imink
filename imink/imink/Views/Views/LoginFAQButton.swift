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
            Spacer()
            
            Image("Ika_d")
                .resizable()
                .foregroundColor(.systemGray2)
                .frame(width: 18, height: 18)
            
            Text("登录问题解答")
                .font(.system(size: 14))
                .foregroundColor(Color("AppLabelColor"))
            
            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.systemGray2)
            
            Spacer()
        }
        .frame(height: 42)
        .background(Color.systemBackground)
        .colorScheme(.light)
    }
}

struct LoginFAQButton_Previews: PreviewProvider {
    static var previews: some View {
        LoginFAQButton()
    }
}
