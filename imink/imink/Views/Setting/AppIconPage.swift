//
//  AppIconPage.swift
//  imink
//
//  Created by Jone Wang on 2021/8/21.
//

import SwiftUI
import SPAlert

enum AppIcon: CaseIterable {
    case main
    case black
    case white
    case salmonRun
    case deepseaMetro
    case toniKensa
    case chaos
    case order
    case squidSquadBand
    case wetFloorBand
    case inkYouUp
    case researchLab
    
    var name: String {
        switch self {
        case .main:
            return "Default"
        case .black:
            return "Black"
        case .white:
            return "White"
        case .salmonRun:
            return "Salmon Run"
        case .deepseaMetro:
            return "Deepsea Metro"
        case .toniKensa:
            return "Toni Kensa"
        case .chaos:
            return "Chaos"
        case .order:
            return "Order"
        case .squidSquadBand:
            return "Squid Squad Band"
        case .wetFloorBand:
            return "Wet Floor Band"
        case .inkYouUp:
            return "INK YOU UP"
        case .researchLab:
            return "Research Lab"
        }
    }
    
    var alternateIconName: String? {
        switch self {
        case .main:
            return nil
        default:
            return name
        }
    }
    
    var previewImageName: String {
        name
    }
}

struct AppIconPage: View {
    @State var currentAlternateIconName = UIApplication.shared.alternateIconName
    
    var body: some View {
        List {
            ForEach(AppIcon.allCases, id: \.self) { appIcon in
                Button(action: {
                    UIApplication.shared.setAlternateIconName(appIcon.alternateIconName)
                    currentAlternateIconName = appIcon.alternateIconName
                }) {
                    HStack(spacing: 16) {
                        Image(appIcon.previewImageName)
                            .frame(width: 60, height: 60)
                            .continuousCornerRadius(13)
                            .overlay(
                                RoundedRectangle(cornerRadius: 13)
                                    .stroke(Color("AppLabelColor"), lineWidth: 0.5)
                                    .opacity(0.05)
                            )
                        
                        Text(appIcon.name.localized)
                            .foregroundColor(Color("AppLabelColor"))
                        
                        Spacer()
                        
                        if currentAlternateIconName == appIcon.alternateIconName {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(AppColor.spPink)
                        }
                    }
                    .padding([.top, .bottom], 8)

                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("App Icon", displayMode: .inline)
    }
}

struct AppIconPage_Previews: PreviewProvider {
    static var previews: some View {
        AppIconPage()
    }
}
