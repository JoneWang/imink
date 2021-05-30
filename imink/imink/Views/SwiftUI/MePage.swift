//
//  MePage.swift
//  imink
//
//  Created by Jone Wang on 2020/10/11.
//

import SwiftUI
import SDWebImageSwiftUI

struct MePage: View {
    
    @StateObject private var viewModel: MeViewModel
    
    @State var showLogoutAlert = false
    @State var showSettings = false
    
    init(isLogined: Bool) {
        _viewModel = StateObject(wrappedValue: MeViewModel(isLogined: isLogined))
    }
    
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
    
    var body: some View {
        let leagueStats = viewModel.records?.records.leagueStats
        let player = viewModel.records?.records.player
        let nicknameAndIcon = viewModel.nicknameAndIcons?.nicknameAndIcons.first
        
        NavigationView {
            
            List {
                Section {
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
                    .listRowBackground(viewModel.isLogined ? .clear : AppColor.listBackgroundColor.opacity(0.8))
                    .modifier(LoginViewModifier(isLogined: viewModel.isLogined, backgroundColor: .clear))
                }
                
                Section {
                    makeRow(image: "globe", text: "Language", link: URL(string: UIApplication.openSettingsURLString), color: .accentColor)
                }
                
                Section {
                    makeRow(image: "chevron.left.slash.chevron.right", text: "Source code", link: URL(string: "https://github.com/JoneWang/imink"), color: .accentColor)
                    makeRow(image: "questionmark.circle", text: "FAQ", link: URL(string: "https://github.com/JoneWang/imink/wiki/FAQ"), color: .accentColor)
                    ZStack {
                        makeDetailRow(image: "tag", text: "About imink", detail: "\(Bundle.main.appVersionShort) (\(Bundle.main.appVersionLong))", color: .accentColor)
                        NavigationLink(destination: AboutPage()) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                #if DEBUG
                Section {
                    ZStack {
                        makeDetailRow(image: "textformat.size", text: "Font Test", detail: "", color: .accentColor)
                        NavigationLink(destination: TestFontView()) {
                            EmptyView()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                #endif
                
                if viewModel.isLogined {
                    Section {
                        HStack {
                            Spacer()
                            
                            Text("Log out")
                                .foregroundColor(.red)
                            
                            Spacer()
                        }
                        .onTapGesture {
                            showLogoutAlert = true
                        }
                        .alert(isPresented: $showLogoutAlert) {
                            Alert(
                                title: Text("Log out"),
                                message: Text("Are you sure you want to log out?"),
                                primaryButton: .destructive(Text("Yes"), action: {
                                    viewModel.logOut()
                                }),
                                secondaryButton: .cancel(Text("No"))
                            )
                        }
                    }
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
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showSettings) {
            SettingPage(showSettings: $showSettings)
        }
    }
    
    func makeLeague(leagueImageName: String, stat: Records.Records.LeagueStats.Stat?, maxPower: Double?) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1.0 / UIScreen.main.scale)
                .foregroundColor(.opaqueSeparator)
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
                        
                        Text(maxPower != nil ? "\(maxPower!)" : "----")
                            .font(.system(size: 10, weight: .semibold).monospacedDigit())
                            .foregroundColor(AppColor.appLabelColor)
                    }
                }
            }
        }
        .padding(0)
    }
    
    func makeRow(image: String,
                 text: LocalizedStringKey,
                 link: URL? = nil,
                 color: Color) -> some View {
        HStack {
            Image(systemName: image)
                .imageScale(.medium)
                .foregroundColor(color)
                .frame(width: 30)
            Group {
                if let link = link {
                    Link(text, destination: link)
                        .foregroundColor(AppColor.appLabelColor)
                } else {
                    Text(text)
                }
            }
            
            Spacer()
            Image(systemName: "chevron.right").imageScale(.medium)
        }
    }
    
    func makeDetailRow(image: String, text: LocalizedStringKey, detail: String, color: Color) -> some View {
        HStack {
            Image(systemName: image)
                .imageScale(.medium)
                .foregroundColor(color)
                .frame(width: 30)
            Text(text)
            Spacer()
            Text(detail)
                .foregroundColor(.gray)
                .font(.callout)
            Image(systemName: "chevron.right").imageScale(.medium)
        }
    }
}

struct MePage_Previews: PreviewProvider {
    static var previews: some View {
        MePage(isLogined: true)
            .preferredColorScheme(.dark)
        MePage(isLogined: true)
    }
}
