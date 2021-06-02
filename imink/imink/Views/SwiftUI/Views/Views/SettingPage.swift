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
import AlertToast

struct SettingPage: View {
    @StateObject private var viewModel = SettingViewModel()
    @StateObject private var iksmSessionViewModel = IksmSessionViewModel()

    @Binding var showSettings: Bool
    
    @State private var showingMailView = false
    @State private var showLogoutAlert = false
    @State private var showReloadWidgetsAlert = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLogined {
                    Section(
                        header: Text("LOGIN STATUS")
                            .font(.system(size: 13))
                            .padding(.leading, 16)
                            .padding(.top, 16),
                        footer: VStack(alignment: .leading, spacing: 8) {
                            if !iksmSessionViewModel.iksmSessionIsValid {
                                Text("Manual Renew_desc")
                                    .font(.system(size: 13))
                                    .padding(.horizontal, 16)
                            }
                            
                            Text("What is an iksm_session?")
                                .font(.system(size: 13))
                                .padding(.leading, 16)
                                .foregroundColor(.accentColor)
                        }
                    ) {
                        HStack {
                            Text("iksm_session")
                                .foregroundColor(AppColor.appLabelColor)
                            
                            Spacer()
                            
                            if iksmSessionViewModel.iksmSessionIsValid {
                                Text("Valid")
                                    .font(.system(size: 16))
                                    .foregroundColor(.green)
                            } else {
                                Text("Expired")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if !iksmSessionViewModel.iksmSessionIsValid {
                            if iksmSessionViewModel.isRenewing {
                                HStack {
                                    Text("Renewing…")
                                        .foregroundColor(AppColor.appLabelColor)
                                    
                                    Spacer()
                                    
                                    ProgressView()
                                }
                            } else {
                                Button(action: {
                                    iksmSessionViewModel.renew()
                                }) {
                                    HStack {
                                        Text("Manual Renew")
                                            .foregroundColor(.accentColor)
                                        
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .animation(.default)
                }
                
                Section(
                    header: Text("GENERAL")
                        .font(.system(size: 13))
                        .padding(.leading, 16)
                        .padding(.top, viewModel.isLogined ? 0 : 16)
                ) {
                    Link(destination: URL(string: UIApplication.openSettingsURLString)!) {
                        ListRow("Language")
                    }

                    Button(action: {
                        WidgetCenter.shared.reloadAllTimelines()
                        showReloadWidgetsAlert = true
                    }) {
                        ListRow("Reload Widgets", titleColor: .accentColor, showArrow: false)
                    }
                }

                Section(
                    header: Text("CONTACT")
                        .font(.system(size: 13))
                        .padding(.leading, 16)
                ) {
                    Link(destination: socialLink) {
                        ListRow(socialName)
                    }

                    if MailView.canSendMail() {
                        Button(action: {
                            showingMailView.toggle()
                        }) {
                            ListRow("Email")
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
                        ListRow("Send Kudos")
                    }
                }

                Section(
                    footer: Text("ABOUT_desc")
                        .font(.system(size: 13))
                        .padding(.horizontal, 16)
                ) {
                    Link(destination: URL(string: "https://github.com/JoneWang/imink/wiki/FAQ")!) {
                        ListRow("FAQ")
                    }

                    NavigationLink(destination: CreditsPage()) {
                        ListRow("Credits", showArrow: false)
                    }

                    Link(destination: URL(string: "https://github.com/JoneWang/imink")!) {
                        ListRow("Source Code")
                    }

                    ListRow(
                        "Version",
                        subtitle: "\(Bundle.main.appVersionShort) (\(Bundle.main.appVersionLong))",
                        showArrow: false
                    )
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
                                    showSettings = false
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
        .toast(isPresenting: $showReloadWidgetsAlert, duration: 1) {
            AlertToast(type: .complete(.primary), title: "")
        }
    }
}

extension SettingPage {
    
    var socialName: LocalizedStringKey {
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
