//
//  BattleListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import SwiftUI
import SwiftUIX

struct BattleListPage: View {
    @StateObject var viewModel = BattleListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundColor(AppColor.listBackgroundColor)
                    .ignoresSafeArea()
                
                CocoaList(viewModel.rows) { row in
                    NavigationLink(
                        destination: BattleDetailPage(
                            id: row.record?.id,
                            rowType: row.type,
                            selectedReocrdId: $viewModel.selectedReocrdId
                        )
                    ) {
                        BattleListItemView(
                            row: row,
                            realtimeLoading: viewModel.isLoadingRealTimeData
                        )
                        .padding(.top, 8)
                        .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listSeparatorStyle(.none)
                .contentInset(.top, 8)
                .contentInset(.bottom, 16)
                .ignoresSafeArea()
            }
            .navigationBarTitle("Salmon Run", displayMode: .inline)
            .navigationBarHidden(false)
        }
    }
}

struct BattleListPage_Previews: PreviewProvider {
    static var previews: some View {
        BattleListPage()
    }
}
