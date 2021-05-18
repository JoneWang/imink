//
//  PlayerSkillView.swift
//  imink
//
//  Created by Jone Wang on 2021/4/3.
//

import SwiftUI
import SDWebImage
import SDWebImageSwiftUI
import InkCore

struct PlayerSkillView: View {
        
    @Binding var victory: Bool
    @Binding var player: Player?
    @StateObject var viewModel: AvatarViewModel

    let onDismiss: () -> Void
    
    var maxWidth: CGFloat {
        (UIScreen.main.bounds.size.width > 428.0) ? 343 : .infinity
    }
    
    var body: some View {
        ZStack {
            if let player = player {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .foregroundColor(.systemGray5)
                            
                            WebImage(url: viewModel.image)
                                .resizable()
                                .clipShape(Circle())
                        }
                        .frame(width: 40, height: 40)
                        
                        Text(player.nickname)
                            .sp2Font(size: 14, color: AppColor.appLabelColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        let skillData = [
                            (player.head, player.headSkills.main, player.headSkills.subs),
                            (player.clothes, player.clothesSkills.main, player.clothesSkills.subs),
                            (player.shoes, player.shoesSkills.main, player.shoesSkills.subs)
                        ]
                        ForEach(0..<skillData.count) { i in
                            let skill = skillData[i]
                            HStack(spacing: 14) {
                                WebImage(url: skill.0.image)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                
                                HStack(spacing: 6) {
                                    ZStack {
                                        Circle()
                                            .foregroundColor(.black)
                                        
                                        ImageView.ability(id: skill.1.id, imageURL: skill.1.image)
                                            .padding(2.5)
                                    }
                                    .frame(width: 30, height: 30)
                                    
                                    ForEach(0..<skill.2.count) { j in
                                        if let sub = skill.2[j] {
                                            ZStack {
                                                Circle()
                                                    .foregroundColor(.black)
                                                
                                                ImageView.ability(id: sub.id, imageURL: sub.image)
                                                    .padding(2)
                                            }
                                            .frame(width: 22, height: 22)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        ImageView.weapon(
                            id: player.weapon.id,
                            imageURL: player.weapon.image)
                            .frame(width: 32, height: 32)
                        
                        Text(player.weapon.name)
                            .sp2Font(size: 14, color: AppColor.appLabelColor)
                        
                        Spacer()
                        
                        
                            ZStack {
                                Circle()
                                    .foregroundColor(.black)
                                
                                ImageView.sub(id: player.weapon.sub.id, isA: victory)
                                    .padding(4)
                            }
                            .frame(width: 24, height: 24)
                        
                            ZStack {
                                Circle()
                                    .foregroundColor(.black)
                                
                                ImageView.special(id: player.weapon.special.id, isA: victory)
                                    .padding(4)
                            }
                            .frame(width: 24, height: 24)
                    }
                    .padding(.leading, 14)
                    .padding(.trailing, 12)
                    .padding(.vertical, 8)
                    .background(Color.quaternarySystemFill)
                    .continuousCornerRadius(10)
                }
                .padding(16)
                .overlay(
                    ZStack {
                        Circle()
                            .foregroundColor(.quaternarySystemFill)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "multiply")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.systemGray)
                    }
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        onDismiss()
                    }, alignment: .topTrailing)
                .frame(height: 310)
                .frame(maxWidth: maxWidth)
                .background(AppColor.listItemBackgroundColor)
                .continuousCornerRadius(18)
                .padding(16)
                .onAppear {
                    viewModel.update(principalId: player.principalId)
                }
                .onChange(of: player) { player in
                    viewModel.update(principalId: player.principalId)
                }
            } else {
                EmptyView()
            }
            
            
        }
    }
}

extension Player: Equatable {
    public static func == (lhs: Player, rhs: Player) -> Bool {
        lhs.principalId == rhs.principalId
    }
}

//import SplatNet2API
//
//struct PlayerSkillView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleData = SplatNet2API.result(battleNumber: "").sampleData
//        let json = String(data: sampleData, encoding: .utf8)!
//        let battle = json.decode(Battle.self)!
//
//        //        StatefulPreviewWrapper(false) { isPresented in
//        VStack {
//            Spacer()
//        }
//        .frame(maxWidth: .infinity)
//        .background(Color.green)
//        .modifier(Popup(isPresented: false,
//                        onDismiss: {
//                        }, content: {
//                            PlayerSkillView(victory: true, player: battle.playerResult.player)
//                        }))
//        .ignoresSafeArea()
//        //        }
//    }
//}
