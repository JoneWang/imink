//
//  BattleRow.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecordRow: View {
    @ObservedObject var model: BattleRecordListCell.CellUpdateModel
    
    var record: Record? {
        model.record
    }
    var body: some View {
        if let record = record {
            ZStack {
                let barValue = Double(record.myPoint) &/ Double((record.myPoint + record.otherPoint))
                
                VStack(spacing: 2) {
                    ZStack {
                        HStack {
                            Text("\(record.battleNumber)")
                                .sp2Font(color: Color.secondary)
                            Spacer()
                        }
                        .opacity(0.5)
                        
                        Text("\(record.victory ? "VICTORY" : "DEFEAT")")
                            .sp1Font(
                                size: 17,
                                color: record.victory ?
                                    AppColor.spPink :
                                    AppColor.spLightGreen
                            )
                    }
                    .padding([.leading, .top], 5)
                    
                    HStack(alignment: .top) {
                        VStack {
                            Text("\(record.gameMode)")
                                .sp1Font(color: Color.secondary)
                            
                            Spacer()
                            
                            Text("\(record.killTotalCount) k  \(record.deathCount) d")
                                .sp2Font(
                                    size: 15,
                                    color: model.isSelected ?
                                        AppColor.recordRowTitleSelectedColor :
                                        AppColor.recordRowTitleNormalColor
                                )
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(record.rule)")
                                .sp1Font(color: Color.secondary)
                            
                            Spacer()
                            
                            Text("\(record.stageName)")
                                .sp2Font(
                                    color: model.isSelected ?
                                        AppColor.recordRowTitleSelectedColor :
                                        AppColor.recordRowTitleNormalColor
                                )
                                .padding(.bottom, 5)
                        }
                    }
                    .padding([.leading, .trailing], 5)
                    
                    Spacer()
                    
                    GeometryReader { geo in
                        HStack(spacing: 0) {
                            Rectangle()
                                .foregroundColor(record.victory ?
                                                    AppColor.spPink :
                                                    AppColor.spLightGreen)
                                .frame(width: CGFloat(barValue) * geo.size.width)
                            
                            Rectangle()
                                .foregroundColor(record.victory ?
                                                    AppColor.spLightGreen :
                                                    AppColor.spPink)
                        }
                    }
                    .frame(height: 5)
                }
                
                WebImage(url: record.weaponImageURL)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(height: 50)
                    .padding(.top, 15)
                
                if !record.isDetail {
                    ProgressView()
                }
            }
            .background(model.isSelected ?
                            Color.accentColor :
                            AppColor.battleListRowBackgroundColor
            )
            .cornerRadius(5)
            .opacity(record.isDetail ? 1 : 0.5)
        } else {
            EmptyView()
        }
    }
}
