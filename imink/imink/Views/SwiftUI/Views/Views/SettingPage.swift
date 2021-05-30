//
//  SettingPage.swift
//  imink
//
//  Created by Jone Wang on 2021/5/30.
//
//

import SwiftUI
import WidgetKit
import StoreKit

struct SettingPage: View {
    @StateObject private var viewModel = SettingViewModel()

    @Binding var showSettings: Bool
    
    @State private var showingMailView = false
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("LOGIN STATUS")
                        .font(.system(size: 13))
                        .padding(.leading, 16)
                        .padding(.top, 16),
                    footer: Text("What is an iksm_session?")
                        .font(.system(size: 13))
                        .padding(.leading, 16)
                        .foregroundColor(.accentColor)
                ) {
                    HStack {
                        Text("iksm_session")
                            .foregroundColor(AppColor.appLabelColor)
                        
                        Spacer()
                        
                        Text("Valid")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                    }
                }
                
                Section(
                    header: Text("GENERAL")
                        .font(.system(size: 13))
                        .padding(.leading, 16)
                ) {
                    Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                        HStack {
                            Text("Language")
                                .foregroundColor(AppColor.appLabelColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right").imageScale(.medium)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                    
                    Button(action: {
                        WidgetCenter.shared.reloadAllTimelines()
                    }) {
                        HStack {
                            Text("Reload Widgets")
                                .foregroundColor(.accentColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right").imageScale(.medium)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                }
                
                Section(
                    header: Text("CONTACT")
                        .font(.system(size: 13))
                        .padding(.leading, 16)
                ) {
                    Link(destination: socialLink) {
                        HStack {
                            Text(socialName)
                                .foregroundColor(AppColor.appLabelColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right").imageScale(.medium)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                    
                    if MailView.canSendMail() {
                        Button(action: {
                            showingMailView.toggle()
                        }) {
                            HStack {
                                Text("Email")
                                    .foregroundColor(AppColor.appLabelColor)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right").imageScale(.medium)
                                    .foregroundColor(.tertiaryLabel)
                            }
                        }
                    }
                }
                
                Section(
                    header: Text("ABOUT")
                        .font(.system(size: 13))
                        .padding(.leading, 16),
                    footer: Text("Send Kudos_desc")
                        .font(.system(size: 13))
                        .padding(.horizontal, 16)
                ) {
                    Button(action: {
                        if let windowScene = UIApplication.shared.windows.first?.windowScene {
                            SKStoreReviewController.requestReview(in: windowScene)
                        }
                    }) {
                        HStack {
                            Text("Send Kudos")
                                .foregroundColor(AppColor.appLabelColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right").imageScale(.medium)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                }
                
                Section(
                    footer: Text("ABOUT_desc")
                        .font(.system(size: 13))
                        .padding(.horizontal, 16)
                ) {
                    Link(destination: URL(string: "https://github.com/JoneWang/imink/wiki/FAQ")!) {
                        HStack {
                            
                            Text("FAQ")
                                .foregroundColor(AppColor.appLabelColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right").imageScale(.medium)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                    
                    Button(action: {}) {
                        HStack {
                            Text("Credits")
                                .foregroundColor(AppColor.appLabelColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right").imageScale(.medium)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                    
                    Link(destination: URL(string: "https://github.com/JoneWang/imink")!) {
                        HStack {
                            Text("Source Code")
                                .foregroundColor(AppColor.appLabelColor)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right").imageScale(.medium)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                    
                    HStack {
                        Text("Version")
                            .foregroundColor(AppColor.appLabelColor)
                        
                        Spacer()
                        
                        Text("\(Bundle.main.appVersionShort) (\(Bundle.main.appVersionLong))")
                            .font(.system(size: 16))
                            .foregroundColor(.secondaryLabel)
                    }
                }
                
                if viewModel.isLogined {
                    Section {
                        Button(action: {
                            showLogoutAlert = true
                        }) {
                            HStack {
                                Spacer()
                                
                                Text("Log out")
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                        }
                        .alert(isPresented: $showLogoutAlert) {
                            Alert(
                                title: Text("Log out"),
                                message: Text("Are you sure you want to log out?"),
                                primaryButton: .destructive(Text("Yes"), action: {
                                    viewModel.logOut()
                                }),
                                secondaryButton: .cancel(Text("No"))
                            )
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showSettings = false
                }) {
                    Text("Done")
                        .foregroundColor(.accentColor)
                        .frame(height: 40)
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingMailView) {
            MailView(isShowing: $showingMailView, recipient: "imink@jone.wang")
        }
    }
}

extension SettingPage {
    
    var socialName: String {
        if AppUserDefaults.shared.currentLanguage == "zh-Hans" {
            return "微博"
        } else {
            return "Twitter"
        }
    }
    
    var socialLink: URL {
        if AppUserDefaults.shared.currentLanguage == "zh-Hans" {
            return URL(string: "https://weibo.com/7582779251")!
        } else {
            return URL(string: "https://Twitter.com/imink_splatoon")!
        }
    }
}

struct SettingPage_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { showSettings in
            SettingPage(showSettings: showSettings)
        }
    }
}
