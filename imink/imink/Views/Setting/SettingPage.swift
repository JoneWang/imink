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
import SPAlert

struct SettingPage: View {
    @StateObject private var iksmSessionViewModel = IksmSessionViewModel()
    @StateObject private var viewModel = SettingViewModel()

    @Binding var showSettings: Bool
    
    @State private var showWhatsIksmSessionView = false
    @State private var showingMailView = false
    @State private var showLogoutAlert = false
    @State private var showReloadWidgetsAlert = false
    @State private var showImportActionSheet = false
    @State private var showFilePicker = false

    @State private var exportPath: Any = ""
    @State private var showExportActivity = false

    var body: some View {
        NavigationView {
            List {
                if viewModel.isLogined {
                    Section(
                        header: SectionHeader {
                            Text("LOGIN STATUS")
                                .padding(.top, 16)
                                .padding(.bottom, 3)
                        },
                        footer: SectionFooter {
                            VStack(alignment: .leading, spacing: 8) {
                                if !iksmSessionViewModel.iksmSessionIsValid {
                                    Text("Manual Renew_desc")
                                        .font(.system(size: 13))
                                }
                                
                                Button(action: {
                                    showWhatsIksmSessionView = true
                                }) {
                                    Text("What is an iksm_session?")
                                        .font(.system(size: 13))
                                        .foregroundColor(.accentColor)
                                }
                                .sheet(isPresented: $showWhatsIksmSessionView) {
                                    WhatsIksmSessionView(isShowing: $showWhatsIksmSessionView)
                                }
                            }
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
                    .alert(isPresented: $iksmSessionViewModel.renewAlert) {
                        Alert(
                            title: Text("Failure to renew"),
                            message: Text("Failure to renew_desc"),
                            dismissButton: .cancel(Text("OK"))
                        )
                    }
                }
                
                Section(
                    header: SectionHeader {
                        Text("GENERAL")
                            .padding(.top, viewModel.isLogined ? 0 : 16)
                            .padding(.bottom,  viewModel.isLogined ? 0 : 3)
                    }
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
                    .spAlert(isPresent: $showReloadWidgetsAlert)
                }
                
                if viewModel.isLogined {
                    Section(
                        header: SectionHeader {
                            Text("USER DATA")
                        },
                        footer: SectionFooter {
                            Text("USER DATA_desc")
                                .font(.system(size: 13))
                        }
                    ) {
                        Button(action: {
                            showImportActionSheet = true
                        }) {
                            ListRow("Import", titleColor: .accentColor, showArrow: false)
                        }
                        .actionSheet(isPresented: $showImportActionSheet) {
                            ActionSheet(
                                title: Text("Import Data"),
                                message: Text("Import Data_desc"),
                                buttons: [
                                    .default(Text("Select File"), action: {
                                        showFilePicker = true
                                    }),
                                    .cancel()
                                ])
                        }
                        .sheet(isPresented: $showFilePicker) {
                            FilePickerView { url in
                                print(url)
                            }
                        }
                        
                        Button(action: {
                            DataBackup.shared.export { finished, progress, exportPath in
                                ProgressHUD.showProgress(CGFloat(progress))
                                
                                if (finished) {
                                    ProgressHUD.dismiss()
                                    
                                    guard let exportPath = exportPath else { return }
                                    self.exportPath = exportPath
                                    showExportActivity = true
                                }
                            }
                        }) {
                            ListRow("Export", titleColor: .accentColor, showArrow: false)
                        }
                        .background(ActivityView(isPresented: $showExportActivity, item: $exportPath))
                    }
                }

                Section(
                    header: SectionHeader {
                        Text("CONTACT")
                    }
                ) {
                    Link(destination: socialLink) {
                        ListRow(socialName)
                    }

                    if MailView.canSendMail() {
                        Button(action: {
                            showingMailView = true
                        }) {
                            ListRow("Email")
                        }
                        .sheet(isPresented: $showingMailView) {
                            MailView(isShowing: $showingMailView, recipient: "imink@jone.wang")
                        }
                    }
                }

                Section(
                    header: SectionHeader {
                        Text("ABOUT")
                    },
                    footer: SectionFooter {
                        Text("Send Kudos_desc")
                            .font(.system(size: 13))
                    }
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
                    footer: SectionFooter {
                        Text("ABOUT_desc")
                            .font(.system(size: 13))
                    }
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
