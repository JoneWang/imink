//
//  AboutPage.swift
//  imink
//
//  Created by Jone Wang on 2020/10/23.
//

import SwiftUI

struct AboutPage: View {
    var body: some View {
        let contributions = [
            "Jone Wang", "Ryan Lau", "Shaw",
            "Key山", "俐吟", "小傘Emp", "米雪", "ai",
            "ddddxxx"
        ]
        ScrollView {
            HStack {
                VStack(alignment: .leading, spacing: 32) {
                    Text(String("About imink"))
                        .sp1Font(size: 30, color: AppColor.appLabelColor)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Disclaimer")
                            .sp1Font(size: 22, color: AppColor.appLabelColor)
                        
                        Text("This app is an unofficial companion app that uses the information of SplatNet 2, and is not affiliated or associated with Nintendo.")
                            .sp2Font(size: 14, color: Color.primary.opacity(0.8), lineLimit: 9)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Contributions")
                            .sp1Font(size: 22, color: AppColor.appLabelColor)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(contributions, id: \.self) { name in
                                Text(name)
                                    .sp2Font(size: 14, color: Color.primary.opacity(0.8))
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("User Group")
                            .sp1Font(size: 22, color: AppColor.appLabelColor)
                        
                        Link(destination: URL(string: "https://t.me/iminkUserGroup")!) {
                            VStack(spacing: 4) {
                                Text("Telegram")
                                    .sp2Font(size: 16, color: .white)
                                Text("https://t.me/iminkUserGroup")
                                    .font(.system(size: 10, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }
                            .padding(12)
                            .background(AppColor.listItemBackgroundColor)
                            .continuousCornerRadius(10)
                        }
                    }
                    
                }
                .padding(.top, 48)
                
                Spacer()
            }
            .padding()
            .padding(.leading, 12)
        }
    }
}

struct AboutPage_Previews: PreviewProvider {
    static var previews: some View {
        AboutPage()
        
        AboutPage()
            .preferredColorScheme(.dark)
    }
}
