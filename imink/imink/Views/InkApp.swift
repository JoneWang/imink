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
                DataBackup.shared.import(url: url) { progress, count, error in
                    ProgressHUD.showProgress(CGFloat(progress))
                    
                    if let error = error {
                        ProgressHUD.dismiss()
                        
                        importError = error
                        showImportAlert = true
                    } else if progress == 1 {
                        ProgressHUD.dismiss()
                        SPAlert.present(
                            title: String(format:"Imported %d records".localized),
                            preset: .done
                        )
                    }
                }
            }
            .alert(isPresented: $showImportAlert) {
                Alert(title: Text("Import Error"), message: Text(importError?.localizedDescription ?? ""))
            }
        }
    }
}
