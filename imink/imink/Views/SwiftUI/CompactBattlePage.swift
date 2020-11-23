//
//  CompactBattlePage.swift
//  imink
//
//  Created by Jone Wang on 2020/9/26.
//

import SwiftUI
import SDWebImageSwiftUI

struct CompactBattlePage: View {
    
    @ObservedObject var model: BattleDetailViewController.UpdateModel
    
    var record: DBRecord? {
        model.record
    }

    var body: some View {
        ZStack {
            if let record = record, let battle = record.battle {
                // Stage as background
                Rectangle().overlay(
                    WebImage(url: battle.stage.image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                )
                
                // Content
                GeometryReader { geo in
                    VStack(alignment: .center, spacing: 0) {
                        // Top content
                        makeBattleInfo(battle: battle, geo: geo)
                            .scaleEffect(0.7)
                        
                        // Bottom content
                        makeTeamContent(battle: battle, geo: geo)
                    }
                    .frame(width: geo.size.width)
                }
            }
        }
        .drawingGroup()
        .edgesIgnoringSafeArea(.all)
    }
    
    func makeBattleInfo(battle: Battle, geo: GeometryProxy) -> some View {
        BattleDataView(battle: battle)
                    .frame(maxHeight: 220)
                    .background(Color.clear)
    }
    
    // Make battle content
    func makeTeamContent(battle: Battle, geo: GeometryProxy) -> some View {
        let teamsDataViewRatio = TeamsDataView.size.width / TeamsDataView.size.height
        let scale = (geo.size.width - 20) / TeamsDataView.size.width
        
        return Rectangle()
            .foregroundColor(.clear)
            .aspectRatio(teamsDataViewRatio, contentMode: .fill)
            .fixedSize(horizontal: false, vertical: true)
            .overlay(
                TeamsDataView(battle: battle)
                    .scaleEffect(scale)
            )
    }
    
}
