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
    
    var body: some View {
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
