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
        let recordsWithIndex = battleListViewModel.records.enumerated().map({ $0 })
        Group {
            #if os(macOS)
            List(recordsWithIndex, id: \.element.id) { index, record in
                if index == 0 {
                    RealtimeRecordRow(
                        isLoading: $battleListViewModel.isLoadingRealTimeBattle,
                        record: record,
                        isSelected: record == selectedRecord,
                        onSelected: { selectedRecord = $0 }
                    )
                } else {
                    RecordRow(
                        record: record,
                        isSelected: record == selectedRecord,
                        onSelected: { selectedRecord = $0 }
                    )
                }
            }
            // !!!: There is a List update bug in macOS that uses id() to force a
            //      List to be rebuilt when records is updated.
            .id(battleListViewModel.records)
            #else
            List(battleListViewModel.records) { record in
                RecordRow(
                    record: record,
                    isSelected: record == selectedRecord,
                    onSelected: { selectedRecord = $0 }
                )
            }
            #endif
        }
        .listStyle(SidebarListStyle())
        .toolbar {
            #if os(macOS)
            ToolbarItem {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                })
            }
            #endif
            
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
        .frame(minWidth: 300)
        .onReceive(battleListViewModel.$records) { records in
            if records.count == 0 { return }
            if selectedRecord != nil { return }
            
            selectedRecord = records.first
        }
    }
    
    private func toggleSidebar() {
        #if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
        #endif
    }
}

struct BattleListView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(nil as Record?) {
            BattleListPage(selectedRecord: $0)
                .preferredColorScheme(.light)
                .frame(width: 300)
        }
        StatefulPreviewWrapper(nil as Record?) {
            BattleListPage(selectedRecord: $0)
                .preferredColorScheme(.dark)
        }
    }
}