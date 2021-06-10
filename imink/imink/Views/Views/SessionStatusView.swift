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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.arrow.circlepath")
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("iksm_session is expired")
                        .font(.headline)
                        .foregroundColor(AppColor.appLabelColor)
                    
                    Text("iksm_session is expired_desc")
                        .font(.system(size: 15))
                        .foregroundColor(.secondaryLabel)
                        .lineSpacing(2)
                }
            }
            .padding(.trailing, 16)
            
            Rectangle()
                .frame(maxWidth: .infinity)
                .frame(height: 1.0 / UIScreen.main.scale)
                .foregroundColor(.separator)
            
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
                        
                        Text("\(Image(systemName: "chevron.right"))")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.tertiaryLabel)
                    }
                }
                .padding(.trailing, 16)
            }
        }
        .padding(.leading, 16)
        .padding(.vertical, 12)
        .background(AppColor.listItemBackgroundColor)
        .continuousCornerRadius(10)
        .sheet(isPresented: $showSettings) {
            SettingPage(showSettings: $showSettings)
        }
    }
}

struct SessionStatusView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            StatefulPreviewWrapper(false) { isRenewing in
                SessionStatusView(isRenewing: isRenewing)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxHeight: .infinity)
        .background(AppColor.listBackgroundColor)
    }
}
