//
//  Text.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import SwiftUI

struct FontModifiers_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello, World!").sp1Font(size: 40)
            Text("Hello, World!").sp2Font(size: 40)
        }
    }
}

extension Text {
    func sp1Font(size: CGFloat = 12, color: Color = .white, lineLimit: Int = 1) -> some View {
        self.modifier(SP1FontModifier(size: size, color: color, lineLimit: lineLimit))
    }
    
    func sp2Font(size: CGFloat = 12, color: Color = .white, lineLimit: Int = 1) -> some View {
        self.modifier(SP2FontModifier(size: size, color: color, lineLimit: lineLimit))
    }
}

extension TextField {
    func sp1Font(size: CGFloat = 12, color: Color = .white, lineLimit: Int = 1) -> some View {
        self.modifier(SP1FontModifier(size: size, color: color, lineLimit: lineLimit))
    }
    
    func sp2Font(size: CGFloat = 12, color: Color = .white, lineLimit: Int = 1) -> some View {
        self.modifier(SP2FontModifier(size: size, color: color, lineLimit: lineLimit))

    }
}

struct SP1FontModifier: ViewModifier {
    var size: CGFloat
    var color: Color
    var lineLimit: Int = 1
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Splatfont", size: size))
            .foregroundColor(color)
            .lineLimit(lineLimit)
            .frame(height: lineLimit == 1 ? size : .infinity)
    }
}

struct SP2FontModifier: ViewModifier {
    var size: CGFloat
    var color: Color
    var lineLimit: Int = 1
    
    func body(content: Content) -> some View {
        content
            .font(.custom("Splatfont2", size: size))
            .foregroundColor(color)
            .lineLimit(lineLimit)
    }
}
