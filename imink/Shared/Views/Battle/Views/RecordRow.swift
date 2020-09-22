//
//  BattleRow.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecordRow: View {
    let record: Record
    let isSelected: Bool
    let onSelected: (Record) -> Void
    
    var body: some View {
        let contentView = ZStack {
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
                            size: 20,
                            color: record.victory ?
                                AppColor.spPink :
                                AppColor.spLightGreen
                        )
                }
                .padding([.leading, .top], 10)
                
                HStack(alignment: .top) {
                    VStack {
                        Text("\(record.gameMode)")
                            .sp1Font(color: Color.secondary)
                        
                        Spacer()
                        
                        Text("\(record.killTotalCount) k  \(record.deathCount) d")
                            .sp2Font(
                                size: 20,
                                color: isSelected ?
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
                                color: isSelected ?
                                    AppColor.recordRowTitleSelectedColor :
                                    AppColor.recordRowTitleNormalColor
                            )
                            .padding(.bottom, 5)
                    }
                }
                .padding([.leading, .trailing], 10)
                
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
                .frame(height: 60)
                .padding(.top, 20)
            
            if !record.isDetail {
                ProgressView()
            }
        }
        .background(isSelected ? Color.accentColor : AppColor.battleListRowBackgroundColor)
        .cornerRadius(10)
        .opacity(record.isDetail ? 1 : 0.5)
        .onTapGesture {
            onSelected(record)
        }
        
        #if os(macOS)
        contentView
            .padding(.bottom)
        #else
        contentView
        #endif
    }
}

struct BattleRow_Previews: PreviewProvider {
    
    static var previews: some View {
        PreviewWrapper()
            .frame(width: 300, height: 230)
            .preferredColorScheme(.dark)
        PreviewWrapper()
            .frame(width: 300, height: 230)
            .preferredColorScheme(.light)
    }
    
    struct PreviewWrapper: View {
        @State var record: Record? = nil
        
        var body: some View {
            VStack {
                if let record = record {
                    RecordRow(record: record, isSelected: false, onSelected: { _ in })
                        .frame(width: 300)
                    RecordRow(record: record, isSelected: true, onSelected: { _ in })
                        .frame(width: 300)
                }
            }
            .onAppear {
                let _ = AppDatabase.shared.records()
                    .sink { _ in
                    } receiveValue: { records in
                        self.record = records[0]
                    }
            }
        }
    }
}
