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
    
    @StateObject private var scheduleViewModel = ScheduleViewModel()
    @StateObject private var salmonRunScheduleViewModel = SalmonRunScheduleViewModel()
    
    var body: some View {
        TabView {
            HomePage(
                viewModel: HomeViewModel(
                    schedulesLoadStatus: scheduleViewModel.$loadStatus.eraseToAnyPublisher(),
                    salmonRunSchedulesLoadStatus: salmonRunScheduleViewModel.$loadStatus.eraseToAnyPublisher()
                ),
                scheduleViewModel: scheduleViewModel,
                salmonRunScheduleViewModel: salmonRunScheduleViewModel
            )
            .tabItem {
                Image("TabBarHome")
                Text("Home")
            }
            .environmentObject(scheduleViewModel)
            .environmentObject(salmonRunScheduleViewModel)
            
            BattleListPage()
                .tabItem {
                    Image("TabBarBattle")
                    Text("Battles")
                }
                .environmentObject(synchronizeBattleViewModel)
            
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
            
            synchronizeBattleViewModel.isLogined = isLogined
            synchronizeJobViewModel.isLogined = isLogined
        }
        .onReceive(NotificationCenter.default.publisher(for: .loginedSuccessed)) { _ in
            mainViewModel.isLogined = true
            synchronizeBattleViewModel.isLogined = true 
            synchronizeJobViewModel.isLogined = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .logout)) { _ in
            // Logout
            synchronizeBattleViewModel.isLogined = false
            synchronizeJobViewModel.isLogined = false
            mainViewModel.isLogined = false
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
