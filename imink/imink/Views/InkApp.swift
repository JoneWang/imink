//
//  InkApp.swift
//  imink
//
//  Created by Jone Wang on 2021/6/4.
//

import SwiftUI

@main
struct InkApp: App {
    
    @State private var showOnboarding = false
    @State private var showUpdatePage = false
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    if AppUserDefaults.shared.firstLaunch {
                        showOnboarding = true
                    } else if AppUserDefaults.shared.firstLaunchAfterUpdating1_1_0 {
                        showUpdatePage = true
                    }
                }
                .sheet(isPresented: $showOnboarding) {
                    OnboardingPage(isPresented: $showOnboarding)
                }
                .sheet(isPresented: $showUpdatePage) {
                    UpdatePage(isPresented: $showUpdatePage)
                }
        }
    }
}
