//
//  BattlePage.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import SwiftUI
import SDWebImageSwiftUI

struct RegularBattlePage: View {
    
    @ObservedObject var model: BattleDetailViewController.UpdateModel
    
    var record: Record? {
        model.record
    }
    
    var body: some View {
        let contentView = Group {
            if let record = record, let battle = record.battle {
                GeometryReader { geo in
                    ZStack {
                        // Stage as background
                        Rectangle().overlay(
                            WebImage(url: battle.stage.imageURL)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .transition(.opacity)
                        )
                        .edgesIgnoringSafeArea(.all)
                        
                        // Content
                        HStack {
                            // Left content
                            makeBattleInfo(battle: battle, geo: geo)
                            
                            // Right content
                            makeTeamContent(battle: battle, geo: geo)
                        }
                        .padding(.init(top: 0, leading: 0, bottom: 60, trailing: 0))
                    }
                    .drawingGroup()
                }
            }
        }
        
        #if os(iOS)
        contentView
        #else
        contentView
        #endif
    }
    
    func makeBattleInfo(battle: SP2Battle, geo: GeometryProxy) -> some View {
        let (teamsDataViewWidth, _) = teamsDataViewWidthAndScale(geo: geo)
        let battleInfoViewWidth = geo.size.width - teamsDataViewWidth
        
        return
            Group {
                if battleInfoViewWidth > 180 {
                    BattleDataView(battle: battle)
                        .frame(maxWidth: battleInfoViewWidth, maxHeight: .infinity)
                        .background(Color.clear)
                } else {
                    Spacer()
                }
            }
    }
    
    // Make battle content
    func makeTeamContent(battle: SP2Battle, geo: GeometryProxy) -> some View {
        let teamsDataViewRatio = TeamsDataView.size.width / TeamsDataView.size.height
        let (_, scale) = teamsDataViewWidthAndScale(geo: geo)
        
        return Rectangle()
            .foregroundColor(.clear)
            .aspectRatio(teamsDataViewRatio, contentMode: .fill)
            .fixedSize(horizontal: false, vertical: true)
            .overlay(
                TeamsDataView(battle: battle)
                    .scaleEffect(scale)
            )
    }
    
    func teamsDataViewWidthAndScale(geo: GeometryProxy) -> (CGFloat, CGFloat) {
        let maxWidth = geo.size.width * (3 / 5)
        
        let displayHeight = geo.size.height
        
        var scale = displayHeight / TeamsDataView.size.height
        var width = scale * TeamsDataView.size.width
        if width > maxWidth {
            width = maxWidth
            scale = width / TeamsDataView.size.width
        }
        
        return (width, scale)
    }
    
}

//struct BattlePage_Previews: PreviewProvider {
//    static var previews: some View {
//        BattlePage()
//            .frame(width: 800, height: 600)
//    }
//}
