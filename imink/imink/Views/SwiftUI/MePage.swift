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
    
    init(isLogined: Bool) {
        _viewModel = StateObject(wrappedValue: MeViewModel(isLogined: isLogined))
    }
    
    var udemaeData: [(LocalizedStringKey, Udemae?)] {
        guard let player = viewModel.records?.records.player else {
            return [
                ("Splat Zones", nil),
                ("Tower Control", nil),
                ("Rainmaker", nil),
                ("Clam Blitz", nil)
            ]
        }
        
        var data = [(LocalizedStringKey, Udemae?)]()
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
        let player = viewModel.records?.records.player
        let nicknameAndIcon = viewModel.nicknameAndIcons?.nicknameAndIcons.first
        
        NavigationView {
            
            List {
                Section {
                    HStack {
                        if (player != nil && nicknameAndIcon != nil) || !viewModel.isLogined {
                            VStack {
                                HStack(alignment: .top) {
                                    if let thumbnailUrl = nicknameAndIcon?.thumbnailUrl {
                                        WebImage(url: thumbnailUrl)
                                            .resizable()
                                            .frame(width: 60, height: 60)
                                            .background(Color.secondary)
                                            .clipShape(Capsule())
                                    } else {
                                        Capsule()
                                            .foregroundColor(.secondary)
                                            .frame(width: 60, height: 60)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
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
                                        .padding(.leading, 4)
                                        
                                        VStack(alignment: .leading, spacing: 0) {
                                            ForEach(udemaeData.indices) { index in
                                                let (gameMode, udemae) = udemaeData[index]
                                                
                                                HStack {
                                                    Text(gameMode)
                                                        .sp2Font(size: 13, color: AppColor.appLabelColor)
                                                    
                                                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                                                        Text(udemae?.name ?? "-")
                                                            .sp1Font(size: 16, color: AppColor.spPink)
                                                        if let sPlusNumber = udemae?.sPlusNumber {
                                                            Text("\(sPlusNumber)")
                                                                .sp1Font(size: 12)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.leading, 4)
                                    }
                                }
                                .padding(.vertical)
                            }
                            
                            Spacer()
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
                                title: Text("Logout"),
                                message: Text("Are you sure you want to logout?"),
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
