//
//  InputView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import SwiftUI

// unused
struct SPTextField: View {
    @Binding var text: String
    var placeholder: String
    var editingChanged: (Bool) -> () = { _ in }
    var commit: () -> () = { }
    
    var body: some View {
        ZStack(alignment: .center) {
            if text == "" {
                Text(placeholder)
                    .sp1Font(size: 20, color: Color.gray)
            }
            
            TextField("", text: $text)
                .textFieldStyle(SplatoonTextFieldStyle())
        }
    }
}

struct SplatoonTextFieldStyle: TextFieldStyle {
    var backgroundColor: Color = .white
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        Rectangle().overlay(
            configuration
                .sp1Font(size: 20, color: .black)
                .textFieldStyle(PlainTextFieldStyle())
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 20)
        )
        .foregroundColor(backgroundColor)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper("123") { content in
            SPTextField(text: content, placeholder: "Client Token")
                .frame(width: 600, height: 60)
        }
    }
}
