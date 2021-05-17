//
//  BattleDetailMemberView.swift
//  imink
//
//  Created by Jone Wang on 2020/12/27.
//

import SwiftUI
import SDWebImageSwiftUI
import InkCore

struct BattleDetailMemberView: View {
    let victory: Bool
    let member: TeamMember
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 7) {
                VStack(spacing: 0) {
                    Text("\(member.player.playerRank)")
                        .sp1Font(size: 16, color: victory ? AppColor.spPink : AppColor.spLightGreen)
                        .frame(width: 24)
                    
                    if member.player.starRank > 0 {
                        HStack(spacing: 1) {
                            Text("★")
                                .sp1Font(size: 8, color: victory ? AppColor.spPink : AppColor.spLightGreen)
                            
                            Text("\(member.player.starRank)")
                                .sp1Font(size: 8, color: victory ? AppColor.spPink : AppColor.spLightGreen)
                        }
                    }
                }
                
                if let udemae = member.player.udemae {
                    Text(udemae.name ?? "C-")
                        .sp1Font(size: 16, color: AppColor.appLabelColor)
                        .frame(width: 24)
                }
            }
            .padding(.bottom, 1)
            .padding(.trailing, 7)
            
            ImageView.weapon(
                id: member.player.weapon.id,
                imageURL: member.player.weapon.image)
                .frame(width: 22, height: 22)
                .foregroundColor(.clear)
                .padding(.trailing, 7)
            
            VStack(alignment: .leading, spacing: 3.5) {
                Text(member.player.nickname)
                    .sp2Font(size: 13, color: AppColor.appLabelColor)
                
                Text("\(member.gamePaintPoint)p")
                    .sp2Font(size: 11, color: .systemGray)
            }
            .padding(.top, 0.5)
            
            Spacer()
            
            HStack(spacing: 10) {
                let speciesName = member.player.playerType.species == .inklings ? "Ika" : "Tako"
                
                VStack(spacing: 2.5) {
                    Image("\(speciesName)_k")
                        .resizable()
                        .foregroundColor(.systemGray3)
                        .frame(width: 16, height: 16)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 1.9) {
                        Text("\(member.killCount + member.assistCount)")
                            .sp2Font(size: 11, color: AppColor.appLabelColor)
                        
                        if member.assistCount > 0 {
                            Text("(\(member.assistCount))")
                                .sp2Font(size: 7, color: AppColor.appLabelColor)
                        }
                    }
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 0, alignment: .center)
                }
                .frame(width: 16)
                
                VStack(spacing: 2.5) {
                    Image("\(speciesName)_d")
                        .resizable()
                        .foregroundColor(.systemGray3)
                        .frame(width: 16, height: 16)
                    
                    Text("\(member.deathCount)")
                        .sp2Font(size: 11, color: AppColor.appLabelColor)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 0, alignment: .center)
                }
                .frame(width: 16)
                
                VStack(spacing: 2.5) {
                    Image("\(speciesName)_kd")
                        .resizable()
                        .foregroundColor(.systemGray3)
                        .frame(width: 16, height: 16)
                    
                    Text("\(Double(member.killCount) -/ Double(member.deathCount), places: 1)")
                        .sp2Font(size: 11, color: AppColor.appLabelColor)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 0, alignment: .center)
                }
                .frame(width: 16)
                
                VStack(spacing: 2.5) {
                    Rectangle()
                        .overlay(
                            ImageView.special(id: member.player.weapon.special.id, isA: victory)
                                .frame(width: 10, height: 10)
                        )
                        .foregroundColor(victory ? AppColor.playerResultSpecialVictoryBackgroundColor : AppColor.playerResultSpecialDefeatBackgroundColor)
                        .frame(width: 14, height: 14)
                        .clipShape(Capsule())
                        .padding(1)
                    
                    Text("\(member.specialCount)")
                        .sp2Font(size: 11, color: AppColor.appLabelColor)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(width: 0, alignment: .center)
                }
                .frame(width: 16)
            }
            .padding(.bottom, 1.5)
        }
        .padding(.leading, 14)
        .padding(.trailing, 13)
        .frame(height: 37)
        .background(isSelected ? .systemGray5 : AppColor.listItemBackgroundColor)
        .clipShape(Capsule())
    }
}

import SplatNet2API

struct BattleDetailMemberView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = SplatNet2API.result(battleNumber: "").sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let battle = json.decode(Battle.self)!
        
        BattleDetailMemberView(victory: true, member: (battle.myTeamMembers?[0])!, isSelected: false)
            .previewLayout(.sizeThatFits)
        BattleDetailMemberView(victory: false, member: (battle.otherTeamMembers?[0])!, isSelected: false)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
