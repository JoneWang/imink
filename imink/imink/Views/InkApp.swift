//
//  InkApp.swift
//  imink
//
//  Created by Jone Wang on 2021/6/4.
//

import SwiftUI
import SPAlert

struct InkApp: View {
    
    @State private var showOnboarding = false
    @State private var showUpdatePage = false
    
    @State private var showImportAlert = false
    @State private var importError: Error?
    
    @State private var showImportingAlert = false
    
    var body: some View {
        Group {
            MainView()
                .onAppear {
                    if AppUserDefaults.shared.firstLaunch {
                        showOnboarding = true
                        AppUserDefaults.shared.firstLaunch = false
                        AppUserDefaults.shared.firstLaunchAfterUpdating1_1_0 = false
                    } else if AppUserDefaults.shared.firstLaunchAfterUpdating1_1_0 {
                        showUpdatePage = true
                        AppUserDefaults.shared.firstLaunchAfterUpdating1_1_0 = false
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
