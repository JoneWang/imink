//
//  BattlePage.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import SwiftUI
import URLImage

struct BattlePage: View {
    @StateObject var battlePageViewModel = BattlePageViewModel()

    var body: some View {
        let defaultImage = Image("BattleDefaultBackground")
            .resizable()
            .aspectRatio(contentMode: .fill)
        
        ZStack {
            if let lastBattle = battlePageViewModel.lastBattle {
                // Stage as background
                Rectangle().overlay(
                    URLImage(lastBattle.stage.imageURL,
                             placeholder: { _ in defaultImage }) { proxy in
                        proxy.image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity)
                    }
                )

                // Content
                GeometryReader { geo in
                    HStack {
                        // Left content
                        BattleDataView(battle: lastBattle)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                        
                        // Right content
                        makeTeamContent(lastBattle: lastBattle, geo: geo)
                    }
                }
            } else {
                // Default background
                Rectangle().overlay(defaultImage)
            }
        }
        .overlay(
            Group {
                // Top leading loading image
                if battlePageViewModel.isLoading {
                    Image("SquidLoading")
                        .resizable()
                        .frame(width: 70, height: 70)
                        .modifier(SwimmingAnimationModifier())
                        .padding([.top, .leading], 20)
                        .shadow(radius: 10)
                }
            },
            alignment: .topLeading
        )
    }
    
    // Make battle content
    func makeTeamContent(lastBattle: SP2Battle, geo: GeometryProxy) -> some View {
        let teamsDataViewRatio = TeamsDataView.size.width / TeamsDataView.size.height
        let teamsDataViewScale = geo.size.height / TeamsDataView.size.height
        return Rectangle()
            .foregroundColor(.clear)
            .aspectRatio(teamsDataViewRatio, contentMode: .fill)
            .fixedSize(horizontal: true, vertical: false)
            .overlay(
                TeamsDataView(battle: lastBattle)
                    .scaleEffect(teamsDataViewScale)
            )
    }
}

struct BattlePage_Previews: PreviewProvider {
    static var previews: some View {
        BattlePage()
            .frame(width: 800, height: 600)
    }
}
