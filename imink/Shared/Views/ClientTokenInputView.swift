//
//  ClientTokenInputView.swift
//  imink-swiftui (iOS)
//
//  Created by Jone Wang on 2020/9/1.
//

import SwiftUI

struct ClientTokenLoginPopupView: View {
    var body: some View {
        let contents: Array<(String, CGFloat)> = [
            ("Welcome to imink :D", 40),
            ("First, \nyou must set up Splatoon2\'s token using @Sp2BattleBot in telegram.", 20),
            ("(How to use the /start command sent to @Sp2BattleBot to learn how to.)", 15),
            ("Second, \nsend the /clienttoken command to @Sp2BattleBot to get the Client Token.", 20),
            ("Finally, \nenter Client Token below.,", 20),
        ]
        return PopupView(
            content: VStack {
                ForEach(contents.indices) { index in
                    Text(contents[index].0)
                        .sp2Font(size: contents[index].1)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black, radius: 2, x: 0, y: 1)
                }
            }.frame(width: 700, height: 500, alignment: .center),
            color: Color("ClientTokenInputBackgroundColor")
        )
    }
}

struct ClientTokenInputView_Previews: PreviewProvider {
    static var previews: some View {
        ClientTokenLoginPopupView()
    }
}
