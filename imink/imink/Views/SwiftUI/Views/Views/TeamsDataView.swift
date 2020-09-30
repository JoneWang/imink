//
//  TeamsDataView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/5.
//

import SwiftUI

struct TeamsDataView: View {
    let battle: SP2Battle
    
    static let size = CGSize(width: 495, height: 610)

    var body: some View {
        VStack(spacing: 20) {
            // Top team
            TeamView(victory: true,
                     me: battle.playerResult.player,
                     members: battle.victoryTeamMembersSorted,
                     color: AppColor.spPink
            )
            .drawingGroup()
            
            // Bottom team
            TeamView(victory: false,
                     me: battle.playerResult.player,
                     members: battle.defeatTeamMembersSorted,
                     color: AppColor.spLightGreen
            )
        }
        .padding()
    }
}

extension SP2Battle {
    var victoryTeamMembersSorted: [SP2TeamMember] {
        [
            SP2TeamResult.Key.victory: myTeamMembersSorted,
            SP2TeamResult.Key.defeat: otherTeamMembersSorted
        ][myTeamResult.key]!
    }
    
    var defeatTeamMembersSorted: [SP2TeamMember] {
        [
            SP2TeamResult.Key.victory: myTeamMembersSorted,
            SP2TeamResult.Key.defeat: otherTeamMembersSorted
        ][otherTeamResult.key]!
    }
    
    var myTeamMembersSorted: [SP2TeamMember] {
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
    
    var otherTeamMembersSorted: [SP2TeamMember] {
        guard let otherTeamMembers = otherTeamMembers else { return [] }
        
        if gameMode.key == .leaguePair || gameMode.key == .leagueTeam  {
            return otherTeamMembers.sorted(by: teamKillSort)
        } else {
            return otherTeamMembers.sorted { $0.sortScore > $1.sortScore }
        }
    }
    
    private func teamKillSort(lMember: SP2TeamMember, rMember: SP2TeamMember) -> Bool {
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

struct TeamsDataView_Previews: PreviewProvider {
    static var previews: some View {
        let battle = Sample.battle()
        return TeamsDataView(battle: battle)
    }
}
