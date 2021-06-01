//
//  ListRow.swift
//  imink
//
//  Created by Jone Wang on 2021/6/1.
//

import SwiftUI

struct ListRow: View {
    let title: LocalizedStringKey
    let titleColor: Color
    let subtitle: LocalizedStringKey?
    let showArrow: Bool
    
    init(_ title: LocalizedStringKey,
         titleColor: Color = AppColor.appLabelColor,
         subtitle: LocalizedStringKey? = nil,
         showArrow: Bool = true) {
        self.title = title
        self.titleColor = titleColor
        self.subtitle = subtitle
        self.showArrow = showArrow
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(titleColor)

            Spacer()
            
            HStack {
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.secondaryLabel)
                }
                
                if showArrow {
                    Text("\(Image(systemName: "chevron.right"))")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.tertiaryLabel)
                }
            }
        }
    }
    
    func makeC() -> some View {
        VStack {
            Text("")
        }
    }
}

struct ListRow_Previews: PreviewProvider {
    static var previews: some View {
        ListRow("")
    }
}
