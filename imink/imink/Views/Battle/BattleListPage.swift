//
//  BattleListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import SwiftUI

struct BattleListPage: View {
    @EnvironmentObject var mainViewModel: MainViewModel
        
    @StateObject var viewModel = BattleListViewModel()
    
    @State private var rows: [BattleListRowModel] = []

    let filterItems: [(String, String)] = [
        ("All Rules", ""), ("Turf War", "RegularBattleMono"),
        ("Splat Zones", "SplatZonesMono"), ("Tower Control", "TowerControlMono"),
        ("Rainmaker", "RainmakerMono"), ("Clam Blitz", "ClamBlitzMono")
    ]
    
    var body: some View {
        if viewModel.isLogined {
            content
                .navigationViewStyle(.automatic)
        } else {
            content
                .navigationViewStyle(.stack)
        }
    }
    
    var content: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(rows, id: \.id) { row in
                        BattleListItemView(
                            row: row,
                            selectedId: $viewModel.selectedId
                        )
                        .padding([.leading, .trailing])
                        .onTapGesture {
                            self.viewModel.selectedId = row.id
                        }
                        .background(
                            NavigationLink(
                                destination: BattleDetailPage(
                                    row: row,
                                    realtimeRow: $viewModel.realtimeRow
                                ),
                                tag: row.id,
                                selection: $viewModel.selectedId
                            ) { EmptyView() }
                            .buttonStyle(PlainButtonStyle())
                        )
                    }
                }
                .padding([.top, .bottom], 16)
            }
            .fixSafeareaBackground()
            .modifier(LoginViewModifier(isLogined: viewModel.isLogined, iconName: "TabBarBattle"))
            .navigationBarTitle("Battles", displayMode: .inline)
            .navigationBarHidden(false)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if viewModel.isLogined {
                        Menu {
                            Picker(selection: $viewModel.currentFilterIndex, label: Text("filtering options")) {
                                ForEach(0..<filterItems.count) { i in
                                    let item = filterItems[i]
                                    HStack{
                                        Text(item.0.localized)
                                        Image(item.1, bundle: Bundle.inkCore)
                                            .foregroundColor(.primary)
                                    }.tag(i)
                                }
                            }
                        }
                        label: {
                            Label("Filter", systemImage: "line.horizontal.3.decrease.circle" + (viewModel.currentFilterIndex == 0 ? "" : ".fill"))
                        }
                    }
                }
            }
        }
        .onReceive(mainViewModel.$isLogined) { isLogined in
            viewModel.updateLoginStatus(isLogined: isLogined)
        }
        .onChange(of: viewModel.rows) { rows in
            withAnimation {
                self.rows = rows
            }
        }
        .onAppear {
            self.rows = viewModel.rows
        }
    }
}

struct BattleListPage_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BattleListViewModel()
        BattleListPage(viewModel: viewModel)
    }
}
