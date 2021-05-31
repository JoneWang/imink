//
//  SessionStatusView.swift
//  imink
//
//  Created by Jone Wang on 2021/5/30.
//

import SwiftUI

struct SessionStatusView: View {
    
    @State var showSettings = false
    @Binding var isRenewing: Bool
    
    var body: some View {
        VStack(spacing: 11) {
            HStack(alignment: .top) {
                Image(systemName: "exclamationmark.arrow.circlepath")
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("iksm_session is expired")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColor.appLabelColor)
                    
                    Text("iksm_session is expired_desc")
                        .font(.system(size: 15))
                        .foregroundColor(.secondaryLabel)
                }
            }
            .padding(.trailing, 16)
            
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1.0 / UIScreen.main.scale)
                .foregroundColor(.opaqueSeparator)
            
            Button(action: {
                showSettings = true
            }) {
                HStack {
                    if isRenewing {
                        Text("Renewing…")
                            .foregroundColor(AppColor.appLabelColor)
                        
                        Spacer()
                        
                        ProgressView()
                    } else {
                        Text("Renew in Settings")
                            .foregroundColor(.accentColor)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right").imageScale(.medium)
                            .foregroundColor(.tertiaryLabel)
                    }
                }
                .padding(.trailing, 16)
            }
        }
        .padding(.leading, 16)
        .padding(.vertical, 11)
        .background(AppColor.listItemBackgroundColor)
        .continuousCornerRadius(10)
        .sheet(isPresented: $showSettings) {
            SettingPage(showSettings: $showSettings)
        }
    }
}

struct SessionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(false) { isRenewing in
            SessionStatusView(isRenewing: isRenewing)
        }
    }
}
