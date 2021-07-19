//
//  NotchBranding.swift
//  imink
//
//  Created by Ryan on 2021/7/19.
//

import SwiftUI

struct NotchBranding: View {
    var body: some View {
        Text("imink")
            .font(.system(size: 13))
            .fontWeight(.medium)
            .foregroundColor(.primary)
            .padding(EdgeInsets(top: 1, leading: 9, bottom: 1, trailing: 8))
            .background(Color.systemGray5)
            .continuousCornerRadius(10)
            .padding(.top, 14)
            .edgesIgnoringSafeArea(.top)
    }
}

struct NotchBranding_Previews: PreviewProvider {
    static var previews: some View {
        NotchBranding()
            .previewLayout(.sizeThatFits)
    }
}
