//
//  BattleListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import SwiftUI

struct BattleListPage: View {
    @StateObject var viewModel = BattleListViewModel()
    
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
                                isSelected: viewModel.selectedId == row.id
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
            }
            .navigationBarTitle("Battles", displayMode: .inline)
            .navigationBarHidden(false)
        }
    }
}

struct BattleListPage_Previews: PreviewProvider {
    static var previews: some View {
        BattleListPage()
    }
}
