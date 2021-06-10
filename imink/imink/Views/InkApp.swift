//
//  InkApp.swift
//  imink
//
//  Created by Jone Wang on 2021/6/4.
//

import SwiftUI
import SPAlert

@main
struct InkApp: App {
    
    @State private var showOnboarding = false
    @State private var showUpdatePage = false
    
    @State private var showImportAlert = false
    @State private var importError: Error?
    
    @State private var showImportingAlert = false
    
    var body: some Scene {
        WindowGroup {
            Group {
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
            .onOpenURL { url in
                DataBackup.import(url: url)
            }
        }
    }
}
