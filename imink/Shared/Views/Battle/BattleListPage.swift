//
//  BattleListView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import SwiftUI

struct CC {
    var id: Int
    var name: String
}

struct BattleListPage: View {
    @StateObject var battleListViewModel = BattleListViewModel()
    
    @Binding var selectedRecord: Record?
    
    var body: some View {
        List(battleListViewModel.records) { record in
            RecordRow(
                record: record,
                isSelected: record == selectedRecord,
                onSelected: { selectedRecord = $0 }
            )
        }
        // !!!: There is a List update bug in macOS that uses id() to force a
        //      List to be rebuilt when records is updated.
        .id(battleListViewModel.records)
        .listStyle(SidebarListStyle())
        .toolbar {
            ToolbarItem {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            
            ToolbarItem { Spacer() }
            
            ToolbarItem {
                // Sync data progress view
                if battleListViewModel.isLoadingDetail {
                    ProgressView(
                        value: Double(battleListViewModel.records.filter { $0.isDetail }.count),
                        total: Double(battleListViewModel.records.count)
                    )
                    .progressViewStyle(CircularProgressViewStyle())
                }
            }
        }
        .frame(minWidth: 270)
        .onReceive(battleListViewModel.$records) { records in
            if records.count == 0 { return }
            if selectedRecord != nil { return }
            
            selectedRecord = records.first
        }
    }
    
    private func toggleSidebar() {
        #if os(iOS)
        #else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

//struct BattleListView_Previews: PreviewProvider {
//    static var previews: some View {
//        StatefulPreviewWrapper(nil as SP2Battle?) {
//            BattleListPage(selectedBattle: $0)
//                .preferredColorScheme(.dark)
//        }
//        StatefulPreviewWrapper(nil as SP2Battle?) {
//            BattleListPage(selectedBattle: $0)
//                .preferredColorScheme(.light)
//        }
//    }
//}
