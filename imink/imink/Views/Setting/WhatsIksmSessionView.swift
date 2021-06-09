//
//  WhatsIksmSessionView.swift
//  imink
//
//  Created by Jone Wang on 2021/6/9.
//

import SwiftUI

struct WhatsIksmSessionView: View {
    @Binding var isShowing: Bool
    
    var items: [(String, LocalizedStringKey)] = [
        ("key", "whats_iksm_session_desc_1"),
        ("timer", "whats_iksm_session_desc_2"),
        ("arrow.triangle.2.circlepath", "whats_iksm_session_desc_3"),
        ("exclamationmark.arrow.circlepath", "whats_iksm_session_desc_4"),
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 28) {
                    Text("Learn more about iksm_session")
                        .font(.title.bold())
                        .foregroundColor(AppColor.appLabelColor)
                    
                    VStack(spacing: 24) {
                        ForEach(items, id: \.0) { item in
                            VStack(spacing: 8) {
                                Image(systemName: item.0)
                                    .font(.largeTitle)
                                    .foregroundColor(.accentColor)
                                    .frame(width: 42, height: 42)
                                
                                Text(item.1)
                                    .font(.subheadline)
                                    .foregroundColor(AppColor.appLabelColor)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 36)
            }
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    isShowing = false
                }) {
                    Text("Done")
                        .foregroundColor(.accentColor)
                        .frame(height: 40)
                }
            )
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { isShowing in
            WhatsIksmSessionView(isShowing: isShowing)
        }
    }
}
