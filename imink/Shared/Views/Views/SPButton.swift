//
//  SPButton.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import SwiftUI

struct SPButton: View {
    let title: LocalizedStringKey?
    let titleString: String
    let color: Color
    let titleColor: Color
    let titleFontSize: CGFloat
    let width: CGFloat
    let action: () -> Void
    
    init(_ titleKey: LocalizedStringKey,
         color: Color = AppColor.spLime,
         titleColor: Color = Color.white,
         titleFontSize: CGFloat = 30,
         width: CGFloat,
         action: @escaping () -> Void
    ) {
        self.title = titleKey
        self.titleString = ""
        self.color = color
        self.titleColor = titleColor
        self.titleFontSize = titleFontSize
        self.width = width
        self.action = action
    }
    
    init(title: String,
         color: Color = AppColor.spLime,
         titleColor: Color = Color.white,
         titleFontSize: CGFloat = 30,
         width: CGFloat,
         action: @escaping () -> Void
    ) {
        self.title = nil
        self.titleString = title
        self.color = color
        self.titleColor = titleColor
        self.titleFontSize = titleFontSize
        self.width = width
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            (title != nil ? Text(title!) : Text(titleString))
                .foregroundColor(titleColor)
                .sp1Font(size: titleFontSize)
                .shadow(radius: 2)
                .frame(width: width, height: 60)
                .background(color)
                .minimumScaleFactor(0.1)
        }
        .buttonStyle(PlainButtonStyle())
        .cornerRadius(30)
    }
}

struct SPButton_Previews: PreviewProvider {
    static var previews: some View {
        SPButton("OK", width: 200) {
            print("ok")
        }
    }
}
