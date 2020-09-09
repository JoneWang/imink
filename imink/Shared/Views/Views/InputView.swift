//
//  InputView.swift
//  imink-swiftui
//
//  Created by Jone Wang on 2020/9/2.
//

import SwiftUI

struct SPInputView: View {
    @Binding var text: String
    var placeholder: String
    var editingChanged: (Bool) -> () = { _ in }
    var commit: () -> () = { }
    
    var body: some View {
        ZStack(alignment: .center) {
            TextField("", text: $text)
                .sp1Font(size: 20, color: .black)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(maxWidth: .infinity)

            if text == "" {
                Text(placeholder)
                    .sp1Font(size: 20, color: Color("InputViewPlaceholderColor"))
            }
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .clipShape(Capsule())
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper("") {
            SPInputView(text: $0, placeholder: "Client Token")
                .frame(width: 600, height: 60, alignment: .center)
        }
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
