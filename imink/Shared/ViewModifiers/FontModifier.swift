//
//  Text.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import SwiftUI

extension View {
    func sp1Font(size: CGFloat = 12, color: Color = .white, lineLimit: Int? = 1) -> some View {
        self.modifier(SP1FontModifier(size: size, color: color, lineLimit: lineLimit))
    }
    
    func sp2Font(size: CGFloat = 12, color: Color = .white, lineLimit: Int? = 1) -> some View {
        self.modifier(SP2FontModifier(size: size, color: color, lineLimit: lineLimit))
    }
}

struct SP1FontModifier: ViewModifier {
    @ScaledMetric var size: CGFloat
    var color: Color
    var lineLimit: Int?
    
    func body(content: Content) -> some View {
        content
            .font(.custom(AppTheme.spFontName, size: size))
            .foregroundColor(color)
            .lineLimit(lineLimit)
            .frame(height: lineLimit == 1 ? size * 1.3: nil)
    }
}

struct SP2FontModifier: ViewModifier {
    var size: CGFloat
    var color: Color
    var lineLimit: Int?
    
    func body(content: Content) -> some View {
        content
            .font(.custom(AppTheme.sp2FontName, size: size))
            .foregroundColor(color)
            .lineLimit(lineLimit)
    }
}

struct FontModifiers_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Group {
                Text("System Text")
                    .font(.system(size: 24))
                
                Text("SplaFont1, S")
                    .sp1Font(size: 24, color: Color.label)
                    .environment(\.sizeCategory, ContentSizeCategory.small)

                Text("SplaFont1, XXL")
                    .sp1Font(size: 24, color: Color.label)
                    .environment(\.sizeCategory, ContentSizeCategory.extraExtraLarge)
                
                Text("SplaFont1,\nNewLine")
                    .sp1Font(size: 24, color: Color.label, lineLimit: nil)
                    .environment(\.sizeCategory, ContentSizeCategory.extraExtraLarge)
                
                Text("SplaFont2, S")
                    .sp2Font(size: 24, color: Color.label)
                    .environment(\.sizeCategory, ContentSizeCategory.small)

                Text("SplaFont2, XXL")
                    .sp2Font(size: 24, color: Color.label)
                    .environment(\.sizeCategory, ContentSizeCategory.extraExtraLarge)
                
                Text("SplaFont2,\nNewLine")
                    .sp2Font(size: 24, color: Color.label, lineLimit: nil)
                    .environment(\.sizeCategory, ContentSizeCategory.extraExtraLarge)
            }
            .border(Color.blue)
            .padding(4)
        }
    }
}
