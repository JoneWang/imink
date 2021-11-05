//
//  CreditsPage.swift
//  imink
//
//  Created by Jone Wang on 2021/6/2.
//

import SwiftUI

struct CreditsPage: View {
    
    let contributors: [Row] = [
        Row(title: "Jone Wang", avatarName: "avatar_jone", subtitle: "Development, Marketing"),
        Row(title: "Ryan Lau", avatarName: "avatar_ryan", subtitle: "UI & Type Design, Marketing"),
        Row(title: "Shaw", avatarName: "avatar_shaw", subtitle: "UI & Icon Design, Marketing"),
        Row(title: "Key山", avatarName: "avatar_key", subtitle: "Simplified Chinese Localization"),
        Row(title: "俐吟", avatarName: "avatar_liyin", subtitle: "Traditional Chinese Localization"),
        Row(title: "小傘Emp", avatarName: "avatar_xiaosan", subtitle: "Traditional Chinese Localization"),
        Row(title: "米雪", avatarName: "avatar_michelc", subtitle: "Traditional Chinese Localization"),
        Row(title: "ai", avatarName: "avatar_ai", subtitle: "Traditional Chinese Localization"),
        Row(title: "ddddxxx", avatarName: "avatar_ddddxxx", subtitle: "Development"),
        Row(title: "泊汐", avatarName: "avatar_boxi", subtitle: "Japanese Localization"),
        Row(title: "Padotagi", avatarName: "avatar_padotagi", subtitle: "Korean Localization, Type Design"),
        Row(title: "issei-m", avatarName: "avatar_isseim", subtitle: "Japanese Localization"),
    ]
    
    let crowdinURL: URL = URL(string: "https://crowdin.com/project/imink")!
    
    let acknowledgements: [Row] = [
        Row(title: "ikaWidget 2", subtitle: "@NexusMine", url: URL(string: "https://twitter.com/NexusMine")),
        Row(title: "splatnet2statink", subtitle: "@frozenpandaman", url: URL(string: "https://github.com/frozenpandaman/splatnet2statink")),
        Row(title: "스플래툰 한글 폰트", subtitle: "Padotagi", url: URL(string: "https://blog.naver.com/wonno79/221083547461")),
    ]
    
    var body: some View {
        List {
            Section(
                header: SectionHeader {
                        if #available(iOS 15.0, *) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("credits_desc")
                                    .font(.system(size: 13))
                                    .offset(y: -10)

                                Text("CONTRIBUTORS")
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 22) {
                            Text("credits_desc")
                                .font(.system(size: 13))
                                .padding(.top, 16)

                                Text("CONTRIBUTORS")
                            }
                            .padding(.bottom, 3)
                        }
                },
                footer: SectionFooter {
                    Link(destination: crowdinURL) {
                        Text("Contribute to localization…")
                            .font(.system(size: 13))
                            .foregroundColor(.accentColor)
                    }
                }
            ) {
                ForEach(0..<contributors.count) { index in
                    makeRow(contributors[index], showSeparator: index != contributors.count - 1)
                }
            }
            .textCase(.none)
            
            Section(
                header: SectionHeader {
                    Text("ACKNOWLEDGEMENTS")
                }
            ) {
                ForEach(0..<acknowledgements.count) { index in
                    Link(destination: acknowledgements[index].url!) {
                        makeRow(acknowledgements[index], showSeparator: index != acknowledgements.count - 1)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Credits", displayMode: .inline)
    }
    
    func makeRow(_ row: Row, showSeparator: Bool = true) -> some View {
        HStack(spacing: 12) {
            if let avatarName = row.avatarName {
                Image(avatarName)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.system(size: 17))
                    .foregroundColor(AppColor.appLabelColor)
                
                Text(genRoleLocalizedText(str: row.subtitle))
                    .font(.system(size: 13))
                    .foregroundColor(Color.secondaryLabel)
            }
            
            Spacer()
            
            if row.url != nil {
                Text("\(Image(systemName: "chevron.right"))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.tertiaryLabel)
            }
        }
        .padding(.vertical, 4)
    }
}

extension CreditsPage {
    struct Row {
        let title: String
        var avatarName: String? = nil
        let subtitle: String
        var url: URL? = nil
    }
}

extension CreditsPage {
    func genRoleLocalizedText(str: String) -> String {
        str.components(separatedBy: ", ")
            .map { $0.localized }
            .joined(separator: ", ".localized)
    }
}

struct CreditsPage_Previews: PreviewProvider {
    static var previews: some View {
        CreditsPage()
    }
}
