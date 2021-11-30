//
//  MePage.swift
//  imink
//
//  Created by Jone Wang on 2020/10/11.
//

import SwiftUI
import SDWebImageSwiftUI

struct MePage: View {
    @EnvironmentObject var mainViewModel: MainViewModel
    
    @StateObject private var viewModel = MeViewModel()
    
    @State var showSettings = false
    
    var udemaeData: [(String, Udemae?)] {
        guard let player = viewModel.records?.records.player else {
            return [
                ("Splat Zones", nil),
                ("Tower Control", nil),
                ("Rainmaker", nil),
                ("Clam Blitz", nil)
            ]
        }
        
        var data = [(String, Udemae?)]()
        if let udemaeZones = player.udemaeZones, udemaeZones.name != nil {
            data.append(("Splat Zones", udemaeZones))
        }
        if let udemaeTower = player.udemaeTower, udemaeTower.name != nil {
            data.append(("Tower Control", udemaeTower))
        }
        if let udemaeRainmaker = player.udemaeRainmaker, udemaeRainmaker.name != nil {
            data.append(("Rainmaker", udemaeRainmaker))
        }
        if let udemaeClam = player.udemaeClam, udemaeClam.name != nil {
            data.append(("Clam Blitz", udemaeClam))
        }
        
        return data
    }
    
    var listRowBackgroundColor: Color {
        if viewModel.isLogined {
            return AppColor.listItemBackgroundColor
        } else {
            if #available(iOS 15.0, *) {
                return AppColor.listItemBackgroundColor.opacity(0.2)
            } else {
                return AppColor.listBackgroundColor.opacity(0.8)
            }
        }
    }
    
    var body: some View {
        let leagueStats = viewModel.records?.records.leagueStats
        let player = viewModel.records?.records.player
        let nicknameAndIcon = viewModel.nicknameAndIcons?.nicknameAndIcons.first
        
        NavigationView {
            
            List {
                Section(
                    footer: VStack(alignment: .center) {
                        Image("Ink")
                            .foregroundColor(Color.tertiaryLabel)
                        
                        Text("Mysterious void under investigation…")
                            .font(.system(size: 13))
                            .foregroundColor(Color.tertiaryLabel)
                    }
                    .padding(.top, 27)
                    .frame(maxWidth: .infinity)
                ) {
                    HStack {
                        if (leagueStats != nil && player != nil && nicknameAndIcon != nil) || !viewModel.isLogined {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top, spacing: 16) {
                                    if let thumbnailUrl = nicknameAndIcon?.thumbnailUrl {
                                        WebImage(url: thumbnailUrl)
                                            .resizable()
                                            .frame(width: 56, height: 56)
                                            .background(Color.systemGray5)
                                            .clipShape(Capsule())
                                    } else {
                                        Capsule()
                                            .foregroundColor(.secondary)
                                            .frame(width: 56, height: 56)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(alignment: .lastTextBaseline) {
                                            Text(player?.nickname ?? "----")
                                                .sp2Font(size: 20, color: AppColor.appLabelColor)
                                                .minimumScaleFactor(0.5)
                                            
                                            Text("\(player?.playerRank ?? 0)")
                                                .sp2Font(size: 16, color: AppColor.spLightGreen)
                                            
                                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                                Text("★")
                                                    .sp1Font(size: 18, color: AppColor.spYellow)
                                                
                                                Text("\(player?.starRank ?? 0)")
                                                    .sp2Font(size: 16, color: AppColor.appLabelColor)
                                            }
                                        }
                                        .padding(.bottom, 7)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            ForEach(udemaeData.indices) { index in
                                                let (gameMode, udemae) = udemaeData[index]
                                                
                                                HStack {
                                                    Text(gameMode.splatNet2Localized)
                                                        .sp2Font(size: 13, color: AppColor.appLabelColor)
                                                    
                                                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                                                        Text(udemae?.name ?? "-")
                                                            .sp1Font(size: 16, color: AppColor.spPink)
                                                        if let sPlusNumber = udemae?.sPlusNumber {
                                                            Text("\(sPlusNumber)")
                                                                .sp1Font(size: 12, color: AppColor.appLabelColor)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.bottom, 16)
                                
                                makeLeague(leagueImageName: "4P", stat: leagueStats?.team, maxPower: player?.maxLeaguePointTeam)
                                    .padding(.bottom, 11)

                                makeLeague(leagueImageName: "2P", stat: leagueStats?.pair, maxPower: player?.maxLeaguePointPair)
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 6)
                        } else {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(viewModel.isLogined ? 1 : 0.2)
                    .modifier(LoginViewModifier(isLogined: viewModel.isLogined, iconName: "TabBarMe", backgroundColor: .clear))
                    .listRowBackground(listRowBackgroundColor)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Me", displayMode: .inline)
            .navigationBarHidden(false)
            .navigationBarItems(trailing:
                Button(action: {
                    showSettings = true
                }) {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "gear")
                            .frame(width: 22, height: 22)
                    }
                    .frame(width: 38, height: 40)
                }
            )
        }
        .navigationViewStyle(.stack)
        .onAppear {
            viewModel.loadUserInfo()
        }
        .onReceive(mainViewModel.$isLogined) { isLogined in
            viewModel.updateLoginStatus(isLogined: isLogined)
        }
        .sheet(isPresented: $showSettings) {
            SettingPage(showSettings: $showSettings)
        }
    }
    
    func makeLeague(leagueImageName: String, stat: Records.Records.LeagueStats.Stat?, maxPower: Double?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1.0 / UIScreen.main.scale)
                .foregroundColor(.separator)
                .padding(.leading, 72)
                .padding(.bottom, 12)
            
            HStack(alignment: .top) {
                HStack {
                    Image(leagueImageName)
                    
                    Spacer()
                }
                .frame(width: 72)
                
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 10) {
                        MedalView(type: .gold, count: stat?.goldCount ?? 0)
                        MedalView(type: .silver, count: stat?.silverCount ?? 0)
                        MedalView(type: .bronze, count: stat?.bronzeCount ?? 0)
                    }
                    
                    HStack(spacing: 5) {
                        Text("Highest Power")
                            .font(.system(size: 10))
                            .foregroundColor(.secondaryLabel)
                        
                        Text(maxPower ?? 0 > 0 ? "\(maxPower!)" : "----")
                            .font(.system(size: 10, weight: .semibold).monospacedDigit())
                            .foregroundColor(AppColor.appLabelColor)
                    }
                }
            }
        }
        .padding(0)
    }
}

struct MePage_Previews: PreviewProvider {
    static var previews: some View {
        MePage()
            .environmentObject(MainViewModel())
            .preferredColorScheme(.dark)
    }
}
