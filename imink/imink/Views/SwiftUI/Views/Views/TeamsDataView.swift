//
//  TeamsDataView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/5.
//

import SwiftUI

struct TeamsDataView: View {
    let battle: Battle
    
    static let size = CGSize(width: 495, height: 610)

    var body: some View {
        VStack(spacing: 20) {
            // Top team
            TeamView(victory: true,
                     me: battle.playerResult.player,
                     members: battle.victoryTeamMembersSorted,
                     color: AppColor.spPink
            )
            
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

struct TeamsDataView_Previews: PreviewProvider {
    static var previews: some View {
        let battle = Sample.battle()
        return TeamsDataView(battle: battle)
    }
}
