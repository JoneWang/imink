//
//  BattleOverviewView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/5.
//

import SwiftUI

struct BattleDataView: View {
    let battle: Battle
    
    var body: some View {
        VStack {
            // Stage name
            Text(battle.stage.name)
                .sp1Font(size: 80)
                .minimumScaleFactor(0.01)
                .padding()
                .padding(.bottom, 0)
                .shadow(radius: 10)
            
            // Gamemode
            VStack {
                Text(battle.gameMode.name)
                    .sp1Font(size: 15, color: AppColor.spRed)
                Text(battle.rule.name)
                    .sp1Font(size: 30, color: .black)
            }
            .minimumScaleFactor(0.01)
            .padding([.leading, .trailing], 25)
            .padding([.top, .bottom], 10)
            .background(Color.white)
            .clipShape(Capsule())
            .shadow(radius: 10)
            .padding([.leading, .trailing])
            
            Spacer()
            
            // Bottom info
            VStack(spacing: 0) {
                // Power
                HStack {
                    if let myPower = battle.myPower {
                        Text("Power: \(myPower)")
                            .sp2Font(size: 30)
                            .padding(.leading, 20)
                    }

                    Spacer()

                    if let otherPower = battle.otherPower {
                        Text("Power: \(otherPower)")
                            .sp2Font(size: 30)
                            .padding(.trailing, 20)
                    }
                }
                .padding(.bottom, 10)
                
                // Progressbar
                BattleResultBar(
                    victory: battle.myTeamResult.key == .victory,
                    leftTitle: battle.myPointTitle,
                    rightTitle: battle.otherPointTitle,
                    value: Double(battle.myPoint) &/
                        Double((battle.myPoint + battle.otherPoint))
                )
                .frame(height: 50)
            }
            .minimumScaleFactor(0.01)
            .padding()
        }
    }
}

extension Battle {
    var myPointTitle: String {
        if myPoint == 100 {
            return "KO BONUS!"
        } else if myPoint == 0 {
            return "0 COUNT"
        } else {
            return "\(myPoint, places: 1)\(rule.key == .turfWar ? "%" : "")"
        }
    }
    
    var otherPointTitle: String {
        if otherPoint == 100 {
            return "KO BONUS!"
        } else if otherPoint == 0 {
            return "0 COUNT"
        } else {
            return "\(otherPoint, places: 1)\(rule.key == .turfWar ? "%" : "")"
        }
    }
}

struct BattleOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        let battle = Sample.battle()
        return BattleDataView(battle: battle)
            .frame(width: 380, height: 500)
            .background(Color.gray)
    }
}
