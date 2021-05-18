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
    @StateObject private var viewModel = BattleDetailViewModel()
    
    let row: BattleListRowModel
    @Binding var realtimeRow: BattleListRowModel?
    
    @State private var showPlayerSkill: Bool = false
    @State private var activePlayer: Player? = nil
    @State private var activePlayerVictory: Bool = false
    @State private var hoveredMember: Bool = false
    
    var navigationTitle: String {
        let title = viewModel.battle?.battleNumber != nil ?
            "ID: \(viewModel.battle!.battleNumber)" : ""
        if row.type == .realtime {
            return "Real-time \(title)"
        } else {
            return title
        }
    }
    
    var body: some View {
        ZStack {
            // FIXME: Fix navigationBar background is white.
            GeometryReader { geometry in
                Rectangle()
                    .fill(AppColor.listBackgroundColor)
                    .frame(height: geometry.safeAreaInsets.top)
                    .edgesIgnoringSafeArea(.top)
                
                Spacer()
            }
            
            ScrollView {
                HStack {
                    Spacer()
                    
                    if let battle = viewModel.battle {
                        makeContent(battle: battle)
                            .padding([.top, .bottom], 20)
                            .frame(maxWidth: 500)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
            }
            .frame(maxWidth: .infinity)
            .background(AppColor.listBackgroundColor)
            .navigationBarTitle(navigationTitle, displayMode: .inline)
            .onAppear {
                viewModel.load(id: row.record?.id)
            }
            .onChange(of: realtimeRow) { row in
                if let row = row {
                    viewModel.load(id: row.record?.id)
                }
            }
        }
        .modifier(Popup(isPresented: showPlayerSkill,
                        onDismiss: {
                            withAnimation {
                                showPlayerSkill = false
                            }
                        }, content: {
                            PlayerSkillView(victory: $activePlayerVictory, player: $activePlayer) {
                                withAnimation {
                                    showPlayerSkill = false
                                }
                            }
                        }))
    }
    
    func makeContent(battle: Battle) -> some View {
        let isGachiX = battle.battleType == .gachi && battle.playerResult.player.udemae?.isX ?? false
        var battleTopDatas: [(String, String)]?
        
        if isGachiX {
            battleTopDatas = [
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
                    .frame(height: 43)
                }
                
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
                                isSelected: member.player == activePlayer && (showPlayerSkill || hoveredMember)
                            )
                            .overlay(
                                TouchDownAndTouchUpGestureView{
                                    activePlayer = member.player
                                    hoveredMember = true
                                } touchMovedCallBack: {distance in
                                    if distance > 10 {
                                        hoveredMember = false
                                    }
                                } touchUpCallBack: {
                                    if hoveredMember {
                                        activePlayer = member.player
                                        activePlayerVictory = victory
                                        withAnimation {
                                            showPlayerSkill = true
                                        }
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

public enum ButtonState {
    case pressed
    case notPressed
}

/// ViewModifier allows us to get a view, then modify it and return it
public struct TouchDownUpEventModifier: ViewModifier {
    
    /// Properties marked with `@GestureState` automatically resets when the gesture ends/is cancelled
    /// for example, once the finger lifts up, this will reset to false
    /// this functionality is handled inside the `.updating` modifier
    @GestureState private var isPressed = false
    
    /// this is the closure that will get passed around.
    /// we will update the ButtonState every time your finger touches down or up.
    let changeState: (ButtonState) -> Void
    
    /// a required function for ViewModifier.
    /// content is the body content of the caller view
    public func body(content: Content) -> some View {
        
        /// declare the drag gesture
        let drag = DragGesture(minimumDistance: 0)
            
            /// this is called whenever the gesture is happening
            /// because we do this on a `DragGesture`, this is called when the finger is down
            .updating($isPressed) { (value, gestureState, transaction) in
                
            /// setting the gestureState will automatically set `$isPressed`
            gestureState = true
        }
        
        return content
        .gesture(drag) /// add the gesture
        .onChange(of: isPressed, perform: { (pressed) in /// call `changeState` whenever the state changes
            /// `onChange` is available in iOS 14 and higher.
            if pressed {
                self.changeState(.pressed)
            } else {
                self.changeState(.notPressed)
            }
        })
    }
    
    /// if you're on iPad Swift Playgrounds and you put all of this code in a seperate file,
    /// you need to add a public init so that the compiler detects it.
    public init(changeState: @escaping (ButtonState) -> Void) {
        self.changeState = changeState
    }
}
