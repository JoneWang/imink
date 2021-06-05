//
//  MainView.swift
//  imink
//
//  Created by Jone Wang on 2021/6/4.
//

import SwiftUI

struct MainView: View {
    @StateObject private var mainViewModel = MainViewModel()
    
    @StateObject private var synchronizeBattleViewModel = SynchronizeBattleViewModel()
    @StateObject private var synchronizeJobViewModel = SynchronizeJobViewModel()
    
    @State private var showLoginView = false
    
    var body: some View {
        TabView {
            HomePage()
                .tabItem {
                    Image("TabBarHome")
                    Text("Home")
                }
            
            BattleListPage()
                .tabItem {
                    Image("TabBarBattle")
                    Text("Battles")
                }
            
            JobListPage()
                .tabItem {
                    Image("TabBarSalmonRun")
                    Text("Salmon Run")
                }
            
            MePage()
                .tabItem {
                    Image("TabBarMe")
                    Text("Me")
                }
        }
        .environmentObject(mainViewModel)
        .onAppear {
            let isLogined = AppUserDefaults.shared.sessionToken != nil
            if isLogined {
                mainViewModel.checkIksmSession()
            }
            mainViewModel.isLogined = isLogined
        }
        .onReceive(NotificationCenter.default.publisher(for: .showLoginView)) { _ in
            showLoginView = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .logout)) { _ in
            // Logout
            synchronizeBattleViewModel.isLogined = false
            synchronizeJobViewModel.isLogined = false
            mainViewModel.isLogined = false
        }
        .sheet(isPresented: $showLoginView) {
            NintendoAccountLoginView() {
                mainViewModel.isLogined = true
                synchronizeBattleViewModel.isLogined = true
                synchronizeJobViewModel.isLogined = true
                
                showLoginView = false
            }
        }
        .alert(isPresented: $mainViewModel.showTokenErrorAlert) {
            Alert(
                title: Text("session_token_invalid_title"),
                message: Text("session_token_invalid_message"),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
