//
//  BattleDetailResultBarView.swift
//  imink
//
//  Created by Jone Wang on 2020/12/27.
//

import SwiftUI

struct BattleDetailResultBarView: View {
    
    let gameRule: GameRule.Key
    let myTeamPoint: Double
    let otherTeamPoint: Double
    let value: CGFloat
    
    private let maskArcOffset: CGPoint = CGPoint(x: 90, y: 10)
    private let maskCircleSize: CGFloat = 100
    private let maskArcFixOffset: CGFloat = 1.5
    
    var body: some View {
        ZStack {
            if value == 0 {
                Image("WaveTexture")
                    .resizable()
                    .frame(height: 34)
                    .foregroundColor(Color("ResultBarBackgroundColor"))
                    .padding(.top, 3)
            } else if value == 1 {
                Image("WaveTexture")
                    .resizable()
                    .frame(height: 34)
                    .foregroundColor(AppColor.spPink)
                    .padding(.top, 3)
            } else {
                GeometryReader { geo in
                    Image("WaveTexture")
                        .resizable()
                        .frame(height: 34)
                        .foregroundColor(myTeamPoint >= otherTeamPoint ? AppColor.spPink : AppColor.spLightGreen)
                        .mask(myTeamBarMask(with: geo.size, progress: value))
                        .overlay(
                            Image("WaveTexture")
                                .resizable()
                                .frame(height: 34)
                                .foregroundColor(Color("ResultBarBackgroundColor"))
                                .mask(otherTeamBarMask(with: geo.size, progress: value)),
                            alignment: .center)
                        .padding(.top, 3)
                }
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(myTeamPoint == 100 ? "KO BONUS!" : "\(myTeamPoint, places: 1)")
                    .sp1Font(size: 16)
                
                Text(myTeamPoint == 100 ? "" : (gameRule == .turfWar ? "%" : " count"))
                    .sp1Font(size: 11)
                
                Spacer()
                
                Text(otherTeamPoint == 100 ? "KO BONUS!" : "\(otherTeamPoint, places: 1)")
                    .sp1Font(size: 16)
                
                Text(otherTeamPoint == 100 ? "" : (gameRule == .turfWar ? "%" : " count"))
                    .sp1Font(size: 11)
            }
            .padding([.leading, .trailing], 15)
        }
        .frame(height: 37)
        .frame(maxWidth: .infinity)
        .background(Color(.sRGB, white: 0.1, opacity: 0.8))
        .clipShape(Capsule())
    }
    
    private func myTeamBarMask(with size: CGSize, progress: CGFloat) -> some View {
        let progress = 1 - self.value
        let maskCircleSize = size.width + self.maskCircleSize
        var shape = Rectangle().path(in: CGRect(origin: .zero, size: size))
        shape.addPath(Circle().path(in: CGRect(x: size.width - progress * size.width - maskArcFixOffset,
                                               y: maskArcOffset.y - (maskCircleSize / 2),
                                               width: maskCircleSize,
                                               height: maskCircleSize)))
        return shape.fill(style: FillStyle(eoFill: true))
    }
    
    private func otherTeamBarMask(with size: CGSize, progress: CGFloat) -> some View {
        let progress = 1 - self.value
        let maskCircleSize = size.width + self.maskCircleSize
        return Circle()
            .frame(width: maskCircleSize, height: maskCircleSize)
            .position(x: size.width + (maskCircleSize / 2) - progress * size.width - maskArcFixOffset, y: maskArcOffset.y)
    }
}

struct BattleDetailResultBarView_Previews: PreviewProvider {
    static var previews: some View {
        BattleDetailResultBarView(gameRule: .splatZones, myTeamPoint: 0, otherTeamPoint: 100, value: 0)
            .frame(width: 414)
            .previewLayout(.sizeThatFits)
        
        BattleDetailResultBarView(gameRule: .towerControl, myTeamPoint: 100, otherTeamPoint: 0, value: 1)
            .frame(width: 414)
            .previewLayout(.sizeThatFits)
        
        BattleDetailResultBarView(gameRule: .turfWar, myTeamPoint: 55, otherTeamPoint: 45, value: 0.2)
            .frame(width: 323)
            .previewLayout(.sizeThatFits)
        
        BattleDetailResultBarView(gameRule: .turfWar, myTeamPoint: 55, otherTeamPoint: 45, value: 0.55)
            .frame(width: 323)
            .previewLayout(.sizeThatFits)
        
        BattleDetailResultBarView(gameRule: .turfWar, myTeamPoint: 55, otherTeamPoint: 45, value: 0.8)
            .frame(width: 323)
            .previewLayout(.sizeThatFits)
        
        BattleDetailResultBarView(gameRule: .turfWar, myTeamPoint: 1, otherTeamPoint: 99, value: 0.00)
            .frame(width: 414)
            .previewLayout(.sizeThatFits)
        
        BattleDetailResultBarView(gameRule: .towerControl, myTeamPoint: 99, otherTeamPoint: 1, value: 0.99)
            .frame(width: 414)
            .previewLayout(.sizeThatFits)
    }
}
