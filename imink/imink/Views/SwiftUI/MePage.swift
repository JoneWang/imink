//
//  MePage.swift
//  imink
//
//  Created by Jone Wang on 2020/10/11.
//

import SwiftUI

struct MePage: View {
    @State var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            
            List {
                Section {
                    makeRow(image: "chevron.left.slash.chevron.right", text: "me_source_code_title", link: URL(string: "https://github.com/JoneWang/imink"), color: .accentColor)
                    makeRow(image: "questionmark.circle", text: "me_faq_title", link: URL(string: "https://github.com/JoneWang/imink/wiki/FAQ"), color: .accentColor)
                    makeDetailRow(image: "tag", text: "me_version_title", detail: "\(Bundle.main.appVersionShort) (\(Bundle.main.appVersionLong))", color: .accentColor)
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Text("me_logout_title")
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        showLogoutAlert = true
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("me_logout_title"),
                            message: Text("Are you sure you want to logout?"),
                            primaryButton: .destructive(Text("button_yes_title"), action: {
                                AppUserDefaults.shared.user = nil
                            }),
                            secondaryButton: .cancel(Text("button_no_title"))
                        )
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Me", displayMode: .inline)
            .navigationBarHidden(false)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func makeRow(image: String,
                 text: LocalizedStringKey,
                 link: URL? = nil,
                 color: Color) -> some View {
        HStack {
            Image(systemName: image)
                .imageScale(.medium)
                .foregroundColor(color)
                .frame(width: 30)
            Group {
                if let link = link {
                    Link(text, destination: link)
                        .foregroundColor(.primary)
                } else {
                    Text(text)
                }
            }
            
            Spacer()
            Image(systemName: "chevron.right").imageScale(.medium)
        }
    }
    
    func makeDetailRow(image: String, text: LocalizedStringKey, detail: String, color: Color) -> some View {
        HStack {
            Image(systemName: image)
                .imageScale(.medium)
                .foregroundColor(color)
                .frame(width: 30)
            Text(text)
            Spacer()
            Text(detail)
                .foregroundColor(.gray)
                .font(.callout)
        }
    }
}

struct MePage_Previews: PreviewProvider {
    static var previews: some View {
        MePage()
            .preferredColorScheme(.dark)
        MePage()
    }
}
