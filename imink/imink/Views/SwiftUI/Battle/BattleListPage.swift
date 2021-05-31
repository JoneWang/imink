//
//  BattleListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import SwiftUI

struct BattleListPage: View {
        
    @StateObject var viewModel: BattleListViewModel
    
    init(viewModel: BattleListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundColor(AppColor.listBackgroundColor)
                    .ignoresSafeArea()
                
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
                .modifier(LoginViewModifier(isLogined: viewModel.isLogined, iconName: "TabBarBattle"))
            }
            .navigationBarTitle("Battles", displayMode: .inline)
            .navigationBarHidden(false)
        }
    }
}

struct BattleListPage_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = BattleListViewModel()
        BattleListPage(viewModel: viewModel)
    }
}
