//
//  BattleRow.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import SwiftUI
import URLImage

struct RecordRow: View {
    let record: Record
    let isSelected: Bool
    let onSelected: (Record) -> Void
    
    @State private var battle: SP2Battle? = nil
    
    var body: some View {
        ZStack {
            if let battle = self.battle {
                let barValue = Double(battle.myPoint) &/ Double((battle.myPoint + battle.otherPoint))
                
                VStack(spacing: 2) {
                    ZStack {
                        HStack {
                            Text("\(battle.battleNumber)")
                                .sp2Font(color: Color.secondary)
                            Spacer()
                        }
                        .opacity(0.5)
                        
                        Text("\(battle.otherTeamResult.name)")
                            .sp1Font(
                                size: 20,
                                color: battle.myTeamResult.key == .victory ?
                                    AppColor.spPink :
                                    AppColor.spLightGreen
                            )
                    }
                    .padding([.leading, .top], 10)
                    
                    HStack(alignment: .top) {
                        Text("\(battle.gameMode.name)")
                            .sp2Font(color: Color.secondary)
                        
                        Spacer()
                        
                        Spacer()
                        
                        Text("\(battle.rule.name)")
                            .sp2Font(color: Color.secondary)
                    }
                    .padding([.leading, .trailing], 10)
                    
                    Spacer()
                    
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle()
                                .foregroundColor(battle.myTeamResult.key == .victory ?
                                                    AppColor.spPink :
                                                    AppColor.spLightGreen)
                                .frame(width: CGFloat(barValue) * geo.size.width)
                            
                            Rectangle()
                                .foregroundColor(battle.myTeamResult.key == .victory ?
                                                    AppColor.spLightGreen :
                                                    AppColor.spPink)
                        }
                    }
                    .frame(height: 5)
                }
                
                URLImage(battle.playerResult.player.weapon.imageURL, placeholder: { _ in
                    Rectangle().foregroundColor(.clear)
                }) { proxy in
                    proxy.image.resizable()
                }
                .aspectRatio(1, contentMode: .fit)
                .frame(height: 60)
                .padding(.top, 20)
                
                if !record.isDetail {
                    ProgressView()
                }
            }
            else {
                EmptyView()
            }
        }
        .frame(height: 90)
        .background(isSelected ? Color.accentColor : AppColor.battleListRowBackgroundColor)
        .cornerRadius(10)
        .padding(.top, 12)
        .opacity(record.isDetail ? 1 : 0.5)
        .onTapGesture {
            onSelected(record)
        }
        .onAppear {
            battle = record.battle//json.decode(SP2Battle.self)
        }
    }
}

//struct BattleRow_Previews: PreviewProvider {
//    static var previews: some View {
//        let overview = Sample.results()
//        let result = overview.results[0]
//        RecordRow(result: result, isSelected: false, onSelected: { _ in })
//            .preferredColorScheme(.dark)
//            .frame(width: 300)
//        RecordRow(result: result, isSelected: true, onSelected: { _ in })
//            .preferredColorScheme(.dark)
//            .frame(width: 300)
//        RecordRow(result: result, isSelected: false, onSelected: { _ in })
//            .preferredColorScheme(.light)
//            .frame(width: 300)
//        RecordRow(result: result, isSelected: true, onSelected: { _ in })
//            .preferredColorScheme(.light)
//            .frame(width: 300)
//    }
//}
