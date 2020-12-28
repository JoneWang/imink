//
//  BattleDetailPage.swift
//  imink
//
//  Created by Jone Wang on 2020/12/25.
//

import SwiftUI
import SDWebImageSwiftUI
import InkCore

struct BattleDetailPage: View {
    
    @ObservedObject var model: BattleDetailViewController.UpdateModel
    
    var battle: Battle {
        model.battle
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 0) {
                    ZStack {
                        GrayscaleTextureView(
                            texture: .streak,
                            foregroundColor: .init(.sRGB, white: 249/255),
                            backgroundColor: .white
                        )
                        
                        VStack {
                            Image("Hook")
                                .foregroundColor(AppColor.listBackgroundColor)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 10) {
                            Image(battle.type.imageName)
                                .resizable()
                                .frame(width: 20, height: 20)
                            
                            HStack(alignment: .bottom) {
                                Text(battle.rule.name.localizedKey)
                                    .sp1Font(size: 14, color: battle.type.color)
                                
                                Spacer()
                                
                                Text(battle.startTimeText)
                                    .sp2Font(size: 12, color: .systemGray)
                                    .padding(.bottom, 0.5)
                            }
                        }
                        .padding([.leading, .trailing], 16)
                        .padding(.top, 1)
                        .frame(height: 43)
                    }
                    
                    ZStack {
                        Rectangle()
                            .overlay(
                                WebImage(url: battle.stage.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .transition(.opacity)
                                
                                ,
                                alignment: .center
                            )
                            .foregroundColor(.systemGray3)
                            .aspectRatio(343/143, contentMode: .fill)
                            .clipped()
                        
                        VStack {
                            Spacer()
                            
                            BattleDetailResultBarView(
                                gameRule: battle.rule.key,
                                myTeamPoint: battle.myPoint,
                                otherTeamPoint: battle.otherPoint,
                                value: CGFloat(battle.myPoint) &/
                                    CGFloat(battle.myPoint + battle.otherPoint)
                            )
                        }
                        .padding([.leading, .bottom, .trailing], 10)
                    }
                    
                    if battle.type == .league {
                        HStack(spacing: 0) {
                            let data = [
                                ("Current", (battle.leaguePoint ?? 0 > 0) ? "\(battle.leaguePoint!)" : "-"),
                                ("Highest", (battle.maxLeaguePoint ?? 0 > 0) ? "\(battle.maxLeaguePoint!)" : "-"),
                                ("Crew", (battle.myEstimateLeaguePoint ?? 0 > 0) ? "\(battle.myEstimateLeaguePoint!)" : "-"),
                                ("Rival", (battle.otherEstimateLeaguePoint ?? 0 > 0) ? "\(battle.otherEstimateLeaguePoint!)" : "-")
                            ]
                            ForEach(data, id: \.0) { item in
                                HStack {
                                    Spacer()
                                    VStack(spacing: 7) {
                                        Text(item.0.localizedKey)
                                            .sp2Font(size: 12, color: .systemGray)
                                        Text(item.1)
                                            .sp2Font(size: 12, color: AppColor.appLabelColor)
                                    }
                                    Spacer()
                                }
                                
                                if item.0 != data.last?.0 {
                                    Rectangle()
                                        .frame(width: 0.7, height: 27)
                                        .foregroundColor(.opaqueSeparator)
                                        .padding(.top, 1)
                                }
                            }
                        }
                        .padding([.top, .bottom], 9.5)
                    } else if battle.type == .gachi {
                        HStack {
                            if let power = battle.estimateXPower {
                                Text("8-Squid \(battle.rule.name) X Power".localizedKey)
                                    .sp2Font(size: 12, color: .systemGray)
                                
                                Spacer()
                                
                                Text("\(power)")
                                    .sp2Font(size: 12, color: AppColor.appLabelColor)
                            }
                            if let power = battle.estimateGachiPower {
                                Text("8-Squid \(battle.rule.name) Power".localizedKey)
                                    .sp2Font(size: 12, color: .systemGray)
                                
                                Spacer()
                                
                                Text("\(power)")
                                    .sp2Font(size: 12, color: AppColor.appLabelColor)
                            }
                        }
                        .padding([.leading, .trailing], 16)
                        .frame(height: 37)
                    }
                }
                .background(AppColor.listItemBackgroundColor)
                .continuousCornerRadius([.topLeft, .topRight], 18)
                .continuousCornerRadius(
                    [.bottomLeft, .bottomRight],
                    (battle.type != .league && battle.type != .gachi) ? 22 : 18
                )
                
                let teams = [battle.victoryTeamMembersSorted, battle.defeatTeamMembersSorted]
                ForEach(0..<teams.count) { i in
                    let victory = i == 0
                    let members = teams[i]

                    VStack(spacing: 6) {
                        ForEach(0..<members.count) { j in
                            let member = members[j]
                            ZStack {
                                BattleDetailMemberView(victory: victory, member: member)
                                
                                if member.player.principalId == battle.playerResult.player.principalId {
                                    Image("MemberArrow")
                                        .foregroundColor(AppColor.memberArrowColor)
                                        .position(x: 1, y: 18.5)
                                }
                            }
                        }
                    }
                }
            }
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 20)
        }
        .background(AppColor.listBackgroundColor)
    }
}

extension Battle {
    
    var startTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        return formatter.string(from: startTime)
    }
    
    var victoryTeamMembersSorted: [TeamMember] {
        [
            TeamResult.Key.victory: myTeamMembersSorted,
            TeamResult.Key.defeat: otherTeamMembersSorted
        ][myTeamResult.key]!
    }
    
    var defeatTeamMembersSorted: [TeamMember] {
        [
            TeamResult.Key.victory: myTeamMembersSorted,
            TeamResult.Key.defeat: otherTeamMembersSorted
        ][otherTeamResult.key]!
    }
    
    var myTeamMembersSorted: [TeamMember] {
        guard let myTeamMembers = myTeamMembers else { return [] }
        
        var members = myTeamMembers
        members.append(playerResult)
        if gameMode.key == .leaguePair || gameMode.key == .leagueTeam {
            members.sort(by: teamKillSort)
        } else {
            members.sort { $0.sortScore > $1.sortScore }
        }
        return members
    }
    
    var otherTeamMembersSorted: [TeamMember] {
        guard let otherTeamMembers = otherTeamMembers else { return [] }
        
        if gameMode.key == .leaguePair || gameMode.key == .leagueTeam  {
            return otherTeamMembers.sorted(by: teamKillSort)
        } else {
            return otherTeamMembers.sorted { $0.sortScore > $1.sortScore }
        }
    }
    
    private func teamKillSort(lMember: TeamMember, rMember: TeamMember) -> Bool {
        let lTotalKill = lMember.killCount + lMember.assistCount
        let rTotalKill = rMember.killCount + rMember.assistCount
        if lTotalKill != rTotalKill {
            return lTotalKill > rTotalKill
        } else if lMember.assistCount != rMember.assistCount {
            return lMember.assistCount > rMember.assistCount
        } else if lMember.deathCount != rMember.deathCount {
            return lMember.deathCount < rMember.deathCount
        } else if lMember.specialCount != rMember.specialCount {
            return lMember.specialCount > rMember.specialCount
        }
        return false
    }
}

import SplatNet2API

struct BattleDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = SplatNet2API.result(battleNumber: "").sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let battle = json.decode(Battle.self)!
        let updateModel = BattleDetailViewController.UpdateModel(battle: battle)
        return BattleDetailPage(model: updateModel)
    }
}
