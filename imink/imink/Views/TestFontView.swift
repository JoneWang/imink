//
//  TestFontView.swift
//  imink
//
//  Created by Jone Wang on 2020/12/20.
//

import SwiftUI

struct TestFontView: View {
    var body: some View {
        VStack(spacing: 10) {
            ForEach(24..<35) { fontSize in
                let fontSize = CGFloat(fontSize)
                let font = Font.custom(AppTheme.spFontName, size: fontSize)
                
                HStack(alignment: .bottom, spacing: 32) {
                    Rectangle()
                        .background(Color.clear)
                        .foregroundColor(Color.clear)
                        .overlay(
                            Text("\(Double(fontSize), places: 0)pt")
                                    .font(.custom("SFMono-Semibold", size: 12))
                                    .frame(height: 12),
                                 alignment: .bottom
                        )
                        .frame(width: 30, height: 5)
                    
                    Text("Hamburgefonstiv")
                        .font(font)
                        .foregroundColor(.yellow)
                        .frame(height: fontSize)
                        .background(Color.accentColor)
                    
                    Spacer()
                }
            }
            
            HStack(alignment: .bottom, spacing: 32) {
                Rectangle()
                    .background(Color.clear)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Text("\(Double(10), places: 0)pt")
                                .font(.custom("SFMono-Semibold", size: 12))
                                .frame(height: 12),
                             alignment: .bottom
                    )
                    .frame(width: 30, height: 5)
                
                Text("1")
                    .sp2Font(size: 10, color: .yellow)
                    .background(Color.accentColor)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 32) {
                Rectangle()
                    .background(Color.clear)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Text("\(Double(10), places: 0)pt")
                                .font(.custom("SFMono-Semibold", size: 12))
                                .frame(height: 12),
                             alignment: .bottom
                    )
                    .frame(width: 30, height: 5)
                
                Text("10")
                    .sp2Font(size: 10, color: .yellow)
                    .background(Color.accentColor)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 32) {
                Rectangle()
                    .background(Color.clear)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Text("\(Double(12), places: 0)pt")
                                .font(.custom("SFMono-Semibold", size: 12))
                                .frame(height: 12),
                             alignment: .bottom
                    )
                    .frame(width: 30, height: 5)
                
                Text("S+")
                    .sp1Font(size: 12, color: .yellow)
                    .background(Color.accentColor)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 32) {
                Rectangle()
                    .background(Color.clear)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Text("\(Double(16), places: 0)pt")
                                .font(.custom("SFMono-Semibold", size: 12))
                                .frame(height: 12),
                             alignment: .bottom
                    )
                    .frame(width: 30, height: 5)
                
                Text("96")
                    .sp1Font(size: 16, color: .yellow)
                    .background(Color.accentColor)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 32) {
                Rectangle()
                    .background(Color.clear)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Text("\(Double(16), places: 0)pt")
                                .font(.custom("SFMono-Semibold", size: 12))
                                .frame(height: 12),
                             alignment: .bottom
                    )
                    .frame(width: 30, height: 5)
                
                Text("61")
                    .sp1Font(size: 16, color: .yellow)
                    .background(Color.accentColor)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 32) {
                Rectangle()
                    .background(Color.clear)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Text("\(Double(16), places: 0)pt")
                                .font(.custom("SFMono-Semibold", size: 12))
                                .frame(height: 12),
                             alignment: .bottom
                    )
                    .frame(width: 30, height: 5)
                
                Text("61")
                    .sp1Font(size: 16, color: .yellow)
                    .background(Color.accentColor)
                
                Spacer()
            }
            
            HStack(alignment: .bottom, spacing: 32) {
                Rectangle()
                    .background(Color.clear)
                    .foregroundColor(Color.clear)
                    .overlay(
                        Text("\(Double(12), places: 0)pt")
                                .font(.custom("SFMono-Semibold", size: 12))
                                .frame(height: 12),
                             alignment: .bottom
                    )
                    .frame(width: 30, height: 5)
                
                Text("p Hamburgefonstiv")
                    .sp1Font(size: 12, color: .yellow)
                    .frame(height: 14)
                    .background(Color.accentColor)
                
                Spacer()
            }
            
            Spacer()
        }
        .padding(.top, 18)
        .padding(.leading, 16)
    }
}

struct TestFontView_Previews: PreviewProvider {
    static var previews: some View {
        TestFontView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11 Pro")
    }
}

struct FontWithLineHeight: ViewModifier {
    let font: UIFont
    let lineHeight: CGFloat

    func body(content: Content) -> some View {
        content
            .font(Font(font))
            .lineSpacing(lineHeight - font.lineHeight)
            .padding(.vertical, (lineHeight - font.lineHeight) / 2)
    }
}
