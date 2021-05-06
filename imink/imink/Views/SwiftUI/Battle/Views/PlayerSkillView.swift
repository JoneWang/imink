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
    
    @StateObject private var viewModel = AvatarViewModel()
    
    @Binding var victory: Bool
    @Binding var player: Player?

    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            if let player = player {
                VStack(spacing: 18) {
                    VStack(spacing: 8) {
                        ImageView(url: viewModel.image)
                            .frame(width: 40, height: 40)
                            .background(Color.systemGray5)
                            .clipShape(Circle())
                        
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
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .overlay(
                                        ImageView(url: skill.0.image)
                                    )
                                    .frame(width: 32, height: 32)
                                    .clipped()
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .foregroundColor(.black)
                                        .overlay(
                                            ImageView(url: skill.1.image)
                                                .padding(2.5)
                                        )
                                        .frame(width: 30, height: 30)
                                    
                                    ForEach(0..<skill.2.count) { j in
                                        if let sub = skill.2[j] {
                                            Circle()
                                                .foregroundColor(.black)
                                                .overlay(
                                                    ImageView(url: sub.image)
                                                        .padding(2)
                                                )
                                                .frame(width: 22, height: 22)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        WeaponImageView(
                            id: player.weapon.id,
                            imageURL: player.weapon.image)
                            .frame(width: 32, height: 32)
                        
                        Text(player.weapon.name)
                            .sp2Font(size: 14, color: AppColor.appLabelColor)
                        
                        Spacer()
                        
                        Circle()
                            .foregroundColor(.black)
                            .overlay(
                                ImageView(url: victory ?
                                            player.weapon.sub.imageA :
                                            player.weapon.sub.imageB
                                )
                                .padding(4)
                            )
                            .frame(width: 24, height: 24)
                        
                        Circle()
                            .foregroundColor(.black)
                            .overlay(
                                ImageView(url: victory ?
                                            player.weapon.special.imageA :
                                            player.weapon.special.imageB
                                )
                                .padding(4)
                            )
                            .frame(width: 24, height: 24)
                    }
                    .padding(.leading, 14)
                    .padding(.trailing, 12)
                    .padding(.vertical, 8)
                    .background(Color.quaternaryLabel)
                    .continuousCornerRadius(10)
                }
                .padding(16)
                .overlay(
                    ZStack {
                        Circle()
                            .foregroundColor(.quaternaryLabel)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "multiply")
                            .foregroundColor(.systemGray)
                            .frame(width: 9.42, height: 9.42)
                    }
                    .frame(width: 40, height: 40)
                    .onTapGesture {
                        onDismiss()
                    }, alignment: .topTrailing)
                .frame(height: 310)
                .frame(maxWidth: .infinity)
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



import FetchImage

struct ImageView: View {
    let url: URL?
    
    @StateObject private var image = FetchImage()
    
    var body: some View {
        ZStack {
            image.view?
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        }
        .onChange(of: url, perform: { url in
            image.reset()
            guard let url = url else {
                return
            }
            image.load(url)
        })
        .onAppear {
            guard let url = url else {
                return
            }
            image.load(url)
        }
        .onDisappear(perform: image.reset)
    }
}

//import NetworkImage
//
//struct ImageView: View {
//
//    let url: URL?
//
//    var body: some View {
//        NetworkImage(url: url)
//            .scaledToFit()
//    }
//}

//struct ImageView: View {
//
//    let url: URL?
//
//    @State private var image: UIImage? = nil
//
//    var body: some View {
//        ZStack {
//            if let image = image {
//                Image(uiImage: image)
//                    .resizable()
//            } else {
//                Image("Empty")
//                    .resizable()
//            }
//        }
//        .transition(.fade)
//        .onChange(of: url, perform: { url in
//            image = nil
//            self.load(url: url)
//        })
//        .onAppear(perform: {
//            self.load(url: url)
//        })
//        .onDisappear(perform: {
//            image = nil
//        })
//    }
//
//    private func load(url: URL?) {
//        guard let url = url else {
//            return
//        }
//
//        if SDImageCache.shared.diskImageDataExists(withKey: url.absoluteString) {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
//                image = SDImageCache.shared.imageFromCache(forKey: url.absoluteString)
//            }
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
//                SDWebImageDownloader.shared.downloadImage(with: url) { (downloadedImage, data, error, finished) in
//                    if let downloadedImage = downloadedImage, finished {
//                        image = downloadedImage
//                    }
//                }
//            }
//        }
//    }
//}
