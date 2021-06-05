//
//  UpdatePage.swift
//  imink
//
//  Created by Jone Wang on 2021/5/18.
//

import SwiftUI

struct UpdatePage: View {
    
    @Binding var isPresented: Bool

    private let largeWidth: CGFloat = 500
    private let iPadMaxHeightPadding: CGFloat = 44 * 2
    
    var body: some View {
        GeometryReader { geo in
            let largeLayout = geo.size.width > largeWidth
            let widthGreaterThan400 = geo.size.width > 400
            let fullscreen = geo.safeAreaInsets.bottom > 0
                        
            makeContent(
                largeLayout: largeLayout,
                widthGreaterThan400: widthGreaterThan400,
                fullscreen: fullscreen
            )
        }
    }
    
    func makeContent(largeLayout: Bool, widthGreaterThan400: Bool, fullscreen: Bool) -> some View {
        let titlePaddingTop: CGFloat = largeLayout ? 66 : (fullscreen ? 80 : 60)
        let titlePaddingBottom: CGFloat = largeLayout || fullscreen ? 57 : 37
        
        return VStack {
            VStack(spacing: 0) {
                Text(largeLayout ? "What’s New in imink" : "What’s New in imink_multi-line")
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.bottom, titlePaddingBottom)
                
                VStack(alignment: .leading, spacing: widthGreaterThan400 ? 46 : 24) {
                    ForEach(
                        [
                            ("UpdateLogLoadout", "Gear Loadout", "update_1_1_0_description_1"),
                            ("UpdateLogMedal", "League Battle Medals", "update_1_1_0_description_2"),
                            ("UpdateLogXRank", "X Rank Improvements", "update_1_1_0_description_3")
                        ],
                        id: \.0
                    ) { iconName, title, description in
                        HStack(spacing: 13) {
                            Image(iconName)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(title.localizedKey)
                                    .font(.system(size: 15, weight: .semibold))
                                
                                Text(description.localizedKey)
                                    .font(.system(size: 15))
                                    .lineSpacing(2)
                                    .foregroundColor(.systemGray)
                            }
                        }
                    }
                }
                .padding(.horizontal, largeLayout ? 110 : (widthGreaterThan400 ? 53 : 34))
                
                Spacer()
                
                HStack {
                    Text("Continue")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                }
                .frame(height: 50)
                .frame(maxWidth: 360)
                .background(Color.accentColor)
                .continuousCornerRadius(14)
                .padding(.horizontal, widthGreaterThan400 ? 44 : 24)
                .onTapGesture {
                    isPresented = false
                }
            }
            .padding(.top, titlePaddingTop)
            .padding(.bottom, !largeLayout || fullscreen ? 55 : 60)
        }
        .frame(maxWidth: .infinity)
    }
}

struct UpdatePage_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { show in
            UpdatePage(isPresented: show)
                .previewLayout(.sizeThatFits)
        }
        
        StatefulPreviewWrapper(true) { show in
            UpdatePage(isPresented: show)
                .previewLayout(.sizeThatFits)
        }
        
        StatefulPreviewWrapper(true) { show in
            UpdatePage(isPresented: show)
                .frame(width: 300, height: 1000)
                .previewLayout(.sizeThatFits)
        }
    }
}
