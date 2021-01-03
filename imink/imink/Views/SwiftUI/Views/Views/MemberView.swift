//
//  MemberCell.swift
//  imink
//
//  Created by Jone Wang on 2020/9/5.
//

import SwiftUI
import SDWebImageSwiftUI
import InkCore

struct MemberView: View {
    let isMe: Bool
    let victory: Bool
    let member: TeamMember?
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                if let member = member {
                    // Level
                    VStack(spacing: 5) {
                        Text("Level")
                            .sp2Font(size: 12)
                        Text("\(member.player.playerRank)")
                            .sp1Font(size: 25)
                    }
                    .frame(width: 40)
                    
                    // Star
                    VStack {
                        Spacer()
                        
                        ForEach(0..<4) { i in
                            if i < member.player.starRank {
                                Text("★")
                                    .sp1Font(size: 10, color: AppColor.spYellow)
                            }
                        }
                    }
                    .padding(.leading, -3)
                    .padding(.bottom, 5)
                    .frame(width: 5)
                    
                    // Rank
                    if let udemae = member.player.udemae {
                        VStack(spacing: 5) {
                            Text("Rank")
                                .sp2Font(size: 12)
                            Text("\((udemae.name?.isEmpty ?? true) ? "🐤" : udemae.name!)")
                                .sp1Font(size: 25)
                        }
                        .frame(width: 40)
                    }
                    
                    // Weapon
                    WeaponImageView(
                        id: member.player.weapon.id,
                        imageURL: member.player.weapon.image)
                        .aspectRatio(1, contentMode: .fit)
                        .overlay(
                            ZStack {
                                Color.black.opacity(0.4)
                                WebImage(url: victory ?
                                            member.player.weapon.sub.imageA :
                                            member.player.weapon.sub.imageB
                                )
                                .resizable()
                                .padding(1)
                            }
                            .frame(width: 18, height: 18)
                            .continuousCornerRadius(4)
                            .padding(.bottom, 1),
                            alignment: .bottomLeading
                        )
                        .padding([.leading, .trailing], 5)
                    
                    // Name
                    VStack(alignment: .leading, spacing: 3) {
                        Text(member.player.nickname)
                            .sp2Font(size: 20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(alignment: .bottom) {
                            Text("\(member.gamePaintPoint)p")
                                .sp2Font(size: 15)
                                .padding(.bottom, 2)
                                .frame(width: 43, alignment: .leading)
                            
                            HStack(alignment: .bottom, spacing: 0) {
                                ForEach([
                                    member.player.headSkills,
                                    member.player.clothesSkills,
                                    member.player.shoesSkills,
                                ], id: \.main.id) { skills in
                                    ZStack {
                                        Color.black
                                        
                                        WebImage(url: skills.main.image)
                                            .resizable()
                                            .padding(1)
                                    }
                                    .frame(width: 20, height: 20)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    
                    // Kill
                    VStack(spacing: 6) {
                        Text("kill")
                            .sp2Font(color: Color.white.opacity(0.7))
                            .padding(2)
                            .background(AppColor.spRed)
                            .continuousCornerRadius(5)
                        
                        HStack(alignment: .bottom, spacing: 0) {
                            Text("\(member.killCount + member.assistCount)")
                                .sp2Font(size: 17)
                            Text("(\(member.assistCount))")
                                .sp2Font(size: 9)
                                .padding(.bottom, 1)
                        }
                    }
                    .frame(width: 40)
                    
                    // Death
                    VStack(spacing: 6) {
                        Text("death")
                            .sp2Font(color: Color.white.opacity(0.7))
                            .padding(2)
                            .background(AppColor.spPurple)
                            .continuousCornerRadius(5)
                        
                        Text("\(member.deathCount)")
                            .sp2Font(size: 17)
                    }
                    
                    // k/d
                    VStack(spacing: 6) {
                        Text("k/d")
                            .sp2Font(color: Color.white.opacity(0.7))
                            .padding(2)
                            .background(AppColor.spLime)
                            .continuousCornerRadius(5)
                        
                        Text("\(Double(member.killCount) -/ Double(member.deathCount), places: 1)")
                            .sp2Font(size: 17)
                    }
                    .frame(width: 35)
                    
                    // Special
                    VStack(spacing: 4) {
                        WebImage(url: victory ?
                                    member.player.weapon.special.imageA :
                                    member.player.weapon.special.imageB
                        )
                        .resizable()
                        .frame(width: 18, height: 18)
                        
                        Text("\(member.specialCount)")
                            .sp2Font(size: 17)
                    }
                    .frame(width: 30)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 5)
            .frame(alignment: .leading)
            .background(Color.black.opacity(0.8))
            .clipShape(Capsule())
            
            if isMe {
                Image("SquidArrow")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .position(x: -15, y: 25)
            }
        }
        .frame(width: 440, height: 50, alignment: .leading)
    }
}

struct MemberCell_Previews: PreviewProvider {
    static var previews: some View {
        let battle = Sample.battle()
        let member = battle.myTeamMembers![0]
        return MemberView(isMe: true, victory: true, member: member)
            .frame(width: 440, height: 50, alignment: .leading)
    }
}
