//
//  BattlePage.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import SwiftUI
import SDWebImageSwiftUI

struct BattlePage: View {
    let record: Record

    var body: some View {
        let contentView = ZStack {
            if let battle = record.battle, record.isDetail {
                // Stage as background
                Rectangle().overlay(
                    WebImage(url: battle.stage.imageURL)
                        .placeholder(Image("BattleDefaultBackground"))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                )

                // Content
                GeometryReader { geo in
                    HStack {
                        // Left content
                        makeBattleInfo(battle: battle, geo: geo)
                        
                        // Right content
                        makeTeamContent(battle: battle, geo: geo)
                    }
                }
            } else {
                // Default background
                Rectangle().overlay(
                    Image("BattleDefaultBackground")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                )
            }
        }
        
        #if os(iOS)
        contentView
            .edgesIgnoringSafeArea(.all)
        #else
        contentView
        #endif
    }
    
    func makeBattleInfo(battle: SP2Battle, geo: GeometryProxy) -> some View {
        let teamsDataViewRatio = TeamsDataView.size.width / TeamsDataView.size.height
        let teamsDataViewWidth = teamsDataViewRatio * geo.size.height
        let battleInfoViewWidth = geo.size.width - teamsDataViewWidth
        
        return
            Group {
            if battleInfoViewWidth > 180 {
                BattleDataView(battle: battle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
            } else {
                Spacer()
            }
        }
    }
    
    // Make battle content
    func makeTeamContent(battle: SP2Battle, geo: GeometryProxy) -> some View {
        let teamsDataViewRatio = TeamsDataView.size.width / TeamsDataView.size.height
        let teamsDataViewScale = geo.size.height / TeamsDataView.size.height
        return Rectangle()
            .foregroundColor(.clear)
            .aspectRatio(teamsDataViewRatio, contentMode: .fill)
            .fixedSize(horizontal: true, vertical: false)
            .overlay(
                TeamsDataView(battle: battle)
                    .scaleEffect(teamsDataViewScale)
            )
    }
}

//struct BattlePage_Previews: PreviewProvider {
//    static var previews: some View {
//        BattlePage()
//            .frame(width: 800, height: 600)
//    }
//}
