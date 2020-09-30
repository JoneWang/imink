//
//  BattleResultBar.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import SwiftUI

struct BattleResultBar: View {
    let victory: Bool
    let leftTitle: String
    let rightTitle: String
    let value: Double
    
    var body: some View {
        ZStack {
            GeometryReader { geo in
                HStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(
                            victory ?
                                AppColor.spPink :
                                AppColor.spLightGreen
                        )
                        .frame(width: CGFloat(value) * geo.size.width)
                    
                    Rectangle()
                        .foregroundColor(
                            victory ?
                                AppColor.spLightGreen :
                                AppColor.spPink
                        )
                }
            }
            
            HStack {
                Text(leftTitle)
                    .sp1Font(size: 30)

                Spacer()
                
                Text(rightTitle)
                    .sp1Font(size: 30)
            }
            .padding([.leading, .trailing], 20)
        }
        .clipShape(Capsule())
        .minimumScaleFactor(0.01)
    }
}

struct BattleResultBar_Previews: PreviewProvider {
    static var previews: some View {
        BattleResultBar(victory: true, leftTitle: "33", rightTitle: "22", value: 0.67)
            .frame(height: 80)
    }
}
