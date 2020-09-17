//
//  MainView.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import SwiftUI

struct MainView: View {
    @StateObject private var mainViewModel = MainViewModel()

    @State private var selectedRecord: Record?

    var body: some View {
        Group {
            if mainViewModel.clientToken != nil {
                NavigationView {
                    BattleListPage(selectedRecord: $selectedRecord)
                    if let record = selectedRecord {
                        BattlePage(record: record)
                    } else {
                        EmptyView()
                    }
                }
            } else {
                LaunchPage(
                    clientToken: $mainViewModel.clientToken,
                    loginUser: $mainViewModel.currentUser
                )
            }
        }.overlay(
            // Show version on all pages.
            Text("\(AppBundle.name) \(AppBundle.version)+\(AppBundle.build)")
                .sp2Font(size: 10, color: Color.white.opacity(0.3))
                .padding(.leading, 20)
                .padding(.bottom, 5),
            alignment: .bottomLeading
        )
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .frame(width: 1000, height: 800)
    }
}
