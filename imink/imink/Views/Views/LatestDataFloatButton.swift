//
//  LatestDataFloatButton.swift
//  imink
//
//  Created by Jone Wang on 2022/6/2.
//

import SwiftUI

struct LatestDataFloatButton: View {
    @Binding var isPresent: Bool
    let title: String
    let action: () -> Void
    
    var body: some View {
        Group {
            if isPresent {
                button
                    .onTapGesture(perform: action)
                    .padding(20)
                    .transition(.move(edge: .bottom))
            } else {
                EmptyView()
            }
        }
        .animation(.easeInOut(duration: 0.25))
    }
    
    var button: some View {
        HStack(spacing: 7) {
            Image(systemName: "chevron.backward.circle.fill")
                .font(.system(size: 14))
                .foregroundColor(.white)
            
            Text(title)
                .sp2Font(size: 13, color: .white)
        }
        .padding(.leading, 11)
        .padding(.trailing, 12)
        .padding(.vertical, 10)
        .frame(height: 36)
        .background(Color.accentColor.transition(.opacity))
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 6)
    }
}

struct LastDataFloatButton_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { isPresent in
            LatestDataFloatButton(isPresent: isPresent, title: "Latest Battle", action: {})
                .previewLayout(.sizeThatFits)
        }
    }
}
