//
//  TeamView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/5.
//

import SwiftUI

struct TeamView: View {
    let victory: Bool
    let me: SP2Player
    let members: [SP2TeamMember]
    let color: Color

    var body: some View {
        ZStack {
            // Background color
            color
                .cornerRadius(40)

            VStack(spacing: 5) {
                // Team title
                Text(victory ? "VICTORY" : "DEFEAT")
                    .sp1Font(size: 40)
                
                // Memebers
                ForEach(0..<4) { i in
                    if let member = members[optional: i] {
                        MemberView(
                            isMe: member.player.principalId == me.principalId,
                            victory: victory,
                            member: member
                        )
                    } else {
                        MemberView(isMe: false, victory: victory, member: nil)
                    }
                }
            }
            .padding(12)
        }
        .fixedSize()
    }
}

struct TeamView_Previews: PreviewProvider {
    static var previews: some View {
        let battle = Sample.battle()
        TeamView(
            victory: true,
            me: battle.playerResult.player,
            members: battle.otherTeamMembers!,
            color: AppColor.spPink
        )
    }
}
