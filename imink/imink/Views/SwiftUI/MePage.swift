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
                    Text("FAQ")
                        .opacity(0.5)
                    Text("About \(Bundle.main.appVersionShort) (\(Bundle.main.appVersionLong))")
                        .opacity(0.5)
                }
                
                Section {
                    HStack {
                        Spacer()
                        
                        Text("Logout")
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                    .onTapGesture {
                        showLogoutAlert = true
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("Logout"),
                            message: Text("Are you sure you want to logout?"),
                            primaryButton: .destructive(Text("Yes!"), action: {
                                AppUserDefaults.shared.user = nil
                            }),
                            secondaryButton: .cancel(Text("No no no!"))
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
}

struct MePage_Previews: PreviewProvider {
    static var previews: some View {
        MePage()
    }
}
