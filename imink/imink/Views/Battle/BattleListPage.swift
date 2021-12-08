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
    
    @State var showFilter: Bool = false
    
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
                    ForEach(viewModel.rows, id: \.id) { row in
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
            .navigationBarItems(trailing:
                Button(action: {
                    showFilter = true
                }) {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .frame(width: 22, height: 22)
                    }
                    .frame(width: 38, height: 40)
                }
            )
        }
        .sheet(isPresented: $showFilter) {
            BattleListFilterPage(
                type: viewModel.filterType,
                rule: viewModel.filterRule,
                stageId: viewModel.filterStageId,
                weaponId: viewModel.filterWeaponId
            ) { type, rule, stageId, weaponId in
                viewModel.filterType = type
                viewModel.filterRule = rule
                viewModel.filterStageId = stageId
                viewModel.filterWeaponId = weaponId
            }
        }
        .onReceive(mainViewModel.$isLogined) { isLogined in
            viewModel.updateLoginStatus(isLogined: isLogined)
        }
    }
}

struct BattleListPage_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BattleListViewModel()
        BattleListPage(viewModel: viewModel)
    }
}
