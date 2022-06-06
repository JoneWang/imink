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
    @StateObject var viewModel: BattleDetailViewModel
    
    let hidePlayerNames: Bool
    
    @Binding var showPlayerSkill: Bool
    @Binding var hoveredMember: Bool
    @Binding var activePlayer: Player?
    @Binding var activePlayerVictory: Bool
    
    @State var battle: Battle? = nil
    @State var showAnimation: Bool = false
    
    var topSafearea: CGFloat = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0
    
    var body: some View {
        ScrollView(.vertical) {
            HStack {
                Spacer()
                
                if let battle = viewModel.battle {
                    makeContent(battle: battle)
                        .padding(.vertical, 20)
                        .frame(maxWidth: 500)
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
            // FIXME: When two ScrollViews are nested. The inner one ScrollView has no safa area.
            .padding(.top, topSafearea + 44)
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeContent(battle: Battle) -> some View {
        let isGachiX = battle.battleType == .gachi && battle.playerResult.player.udemae?.isX ?? false
        var battleTopDatas: [(String, String)]?
        
        if isGachiX {
            battleTopDatas = [
                ("Position", (battle.rank ?? 0 > 0) ? "\(battle.rank!)" : "-"),
                ("My X Power", (battle.xPower ?? 0 > 0) ? "\(battle.xPower!)" : "-"),
                ("Average", (battle.estimateXPower ?? 0 > 0) ? "\(battle.estimateXPower!)" : "-")
            ]
        } else if battle.battleType == .league {
            battleTopDatas = [
                ("Current", (battle.leaguePoint ?? 0 > 0) ? "\(battle.leaguePoint!)" : "-"),
                ("Highest", (battle.maxLeaguePoint ?? 0 > 0) ? "\(battle.maxLeaguePoint!)" : "-"),
                ("Crew", (battle.myEstimateLeaguePoint ?? 0 > 0) ? "\(battle.myEstimateLeaguePoint!)" : "-"),
                ("Rival", (battle.otherEstimateLeaguePoint ?? 0 > 0) ? "\(battle.otherEstimateLeaguePoint!)" : "-")
            ]
        }
        
        return VStack(spacing: 20) {
            VStack(spacing: 0) {
                ZStack {
                    GrayscaleTextureView(
                        texture: .streak,
                        foregroundColor: AppColor.battleDetailStreakForegroundColor,
                        backgroundColor: AppColor.listItemBackgroundColor
                    )
                    
                    VStack {
                        Image("Hook")
                            .foregroundColor(AppColor.listBackgroundColor)
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 10) {
                        Image(battle.battleType.imageName)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        HStack(alignment: .bottom) {
                            Text(battle.rule.localizedName)
                                .sp1Font(size: 14, color: battle.battleType.color)
                            
                            Spacer()
                            
                            Text(battle.startTimeText)
                                .sp2Font(size: 12, color: .systemGray)
                                .padding(.bottom, 0.5)
                        }
                    }
                    .padding([.leading, .trailing], 16)
                    .padding(.top, 1)
                }
                .frame(height: 43)
                
                ZStack {
                    Rectangle()
                        .overlay(
                            ImageView.stage(
                                id: battle.stage.id,
                                imageURL: battle.stage.image,
                                imageURLBehaviour: .replace
                            )
                            .aspectRatio(contentMode: .fill)
                            .transition(.opacity),
                            alignment: .bottom
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
                
                if let battleDatas = battleTopDatas {
                    HStack(spacing: 0) {
                        ForEach(battleDatas, id: \.0) { item in
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

                            if item.0 != battleDatas.last?.0 {
                                Rectangle()
                                    .frame(width: 0.7, height: 27)
                                    .foregroundColor(.opaqueSeparator)
                                    .padding(.top, 1)
                            }
                        }
                    }
                    .padding([.top, .bottom], 9.5)
                } else if battle.battleType == .gachi {
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
                (battle.battleType != .league && battle.battleType != .gachi) ? 24 : 18
            )
            
            let teams = [battle.victoryTeamMembersSorted, battle.defeatTeamMembersSorted]
            ForEach(0..<teams.count) { i in
                let victory = i == 0
                let members = teams[i]
                
                VStack(spacing: 6) {
                    ForEach(0..<members.count) { j in
                        let member = members[j]
                        ZStack {
                            BattleDetailMemberView(
                                victory: victory,
                                member: member,
                                showCrown: battle.crownPlayers?.contains(member.player.principalId) ?? false,
                                isSelected: member.player == activePlayer && (showPlayerSkill || hoveredMember),
                                hidePlayerNames: (member.player.principalId == battle.playerResult.player.principalId) ? false : hidePlayerNames
                            )
                            .overlay(
                                TouchDownAndTouchUpGestureView{
                                    activePlayer = member.player
                                    activePlayerVictory = victory
                                    hoveredMember = true
                                } touchMovedCallBack: {distance in
                                    if distance > 10 {
                                        hoveredMember = false
                                    }
                                } touchUpCallBack: {
                                    if hoveredMember {
                                        showPlayerSkill = true
                                        hoveredMember = false
                                    }
                                }
                            )
                            
                            if member.player.principalId == battle.playerResult.player.principalId {
                                Image("MemberArrow")
                                    .foregroundColor(AppColor.memberArrowColor)
                                    .position(x: 1, y: 18.5)
                            }
                        }
                        // FIXME: Fix the bug of height error on iOS15
                        .frame(height: 37)
                    }
                }
            }
        }
    }
}

extension Battle {
    
    var startTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
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
        guard var myTeamMembers = myTeamMembers else { return [] }
        myTeamMembers.append(playerResult)
        return sorted(teamMembers: myTeamMembers)
    }
    
    var otherTeamMembersSorted: [TeamMember] {
        guard let otherTeamMembers = otherTeamMembers else { return [] }
        return sorted(teamMembers: otherTeamMembers)
    }
    
    private func sorted(teamMembers: [TeamMember]) -> [TeamMember] {
        if gameMode.key == .leaguePair || gameMode.key == .leagueTeam  {
            return teamMembers.sorted(by: teamKillSort)
        } else if gameMode.key == .regular {
            return teamMembers.sorted { $0.gamePaintPoint > $1.gamePaintPoint }
        } else {
            return teamMembers.sorted { $0.sortScore > $1.sortScore }
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

extension Player: Identifiable {
    public var id: String {
        principalId
    }
}


//import SplatNet2API
//
//struct BattleDetailPage_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleData = SplatNet2API.result(battleNumber: "").sampleData
//        let json = String(data: sampleData, encoding: .utf8)!
//        let battle = json.decode(Battle.self)!
//        return BattleDetailPage(row: <#T##BattleListRowModel#>, realtimeRow: <#T##Binding<BattleListRowModel?>#>)
//    }
//}
