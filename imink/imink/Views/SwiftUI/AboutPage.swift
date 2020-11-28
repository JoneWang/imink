//
//  AboutPage.swift
//  imink
//
//  Created by Jone Wang on 2020/10/23.
//

import SwiftUI

struct AboutPage: View {
    var body: some View {
        ScrollView {
            
            VStack(spacing: 48) {
                Text(String("About imink"))
                    .sp1Font(size: 30, color: .primary)
                
                VStack(spacing: 28) {
                    VStack(spacing: 12) {
                        Text("Developer")
                            .sp1Font(size: 22, color: .primary)
                        Text("Jone Wang")
                            .sp2Font(size: 18, color: Color.primary.opacity(0.8))
                    }
                    
                    VStack(spacing: 12) {
                        Text("Designer")
                            .sp1Font(size: 22, color: .primary)
                        Text("Ryan Lau & Shaw")
                            .sp2Font(size: 18, color: Color.primary.opacity(0.8))
                    }
                    
                    VStack(spacing: 12) {
                        Text("Thanks")
                            .sp1Font(size: 22, color: .primary)
                        
                        Text("Key山")
                            .sp2Font(size: 16, color: Color.primary.opacity(0.8))
                        
                        HStack {
                            Text("俐吟")
                                .sp2Font(size: 16, color: Color.primary.opacity(0.8))
                            Text("小傘Emp")
                                .sp2Font(size: 16, color: Color.primary.opacity(0.8))
                            Text("米雪")
                                .sp2Font(size: 16, color: Color.primary.opacity(0.8))
                            Text("ai")
                                .sp2Font(size: 16, color: Color.primary.opacity(0.8))
                        }
                        
                        Text("ddddxxx")
                            .sp2Font(size: 16, color: Color.primary.opacity(0.8))
                    }
                }
                
                VStack(spacing: 28) {
                    VStack(spacing: 12) {
                        Text("User Group")
                            .sp1Font(size: 22, color: .primary)
                        
                        Link(destination: URL(string: "https://t.me/iminkUserGroup")!) {
                            VStack(spacing: 4) {
                                Text("Telegram")
                                    .sp2Font(size: 18, color: .white)
                                Text("https://t.me/iminkUserGroup")
                                    .font(.system(size: 10, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(10)
                        }
                    }
                }
                
            }
            .padding()
            .padding(.top, 48)
        }
    }
}

struct AboutPage_Previews: PreviewProvider {
    static var previews: some View {
        AboutPage()
        AboutPage()
            .preferredColorScheme(.dark)
    }
}
