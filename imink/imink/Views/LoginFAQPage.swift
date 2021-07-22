//
//  LoginFAQPage.swift
//  imink
//
//  Created by Jone Wang on 2021/7/21.
//

import SwiftUI

struct LoginFAQPage: View {
    @State var showingMailView = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    let contents = [
        ("为什么账号密码输入页面提示「要求的内容有误」？", "登录页面是任天堂的官方网页，其网页验证机制与imink无关。提示「要求的内容有误」可能与网络条件不佳，无法触发Google人机验证有关。请尝试更换质量更佳的国际网络连接。"),
        ("为什么我尝试登录时登录按键呈现灰色的不可点击状态？", "登录页面是任天堂的官方网页，其网页验证机制与imink无关。登录键置灰可能与网络条件不佳，无法触发Google人机验证有关。请尝试更换质量更佳的国际网络连接。"),
        ("为什么点击登录后长时间停留在转圈加载页面？", "此情况属于正常现象。请耐心等待，完成授权登录需要一定的时间。"),
        ("为什么登录时出现弹窗提示「登录验证服务器拥挤，请稍后重试。」？ ", "登录过程中imink需要与任天堂服务器和验证服务器多次交换数据，请等待1–2分钟或更换网络环境并再次尝试登录。我们会持续优化登录体验。对于带给您的不便，我们深感抱歉。")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(contents, id: \.0) { content in
                        VStack(alignment: .leading, spacing: 14) {
                            Text(content.0)
                                .font(.body)
                                .fontWeight(.bold)
                            
                            Text(content.1)
                                .font(.subheadline)
                                .foregroundColor(.secondaryLabel)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("使用imink时我的账号安全吗？")
                            .font(.body)
                            .fontWeight(.bold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("登录页面是任天堂的官方网页，imink本质上是模拟 Nintendo Switch Online的登录流程，并且全程采用HTTPS传输您的数据。")
                                .font(.subheadline)
                                .foregroundColor(.secondaryLabel)
                            
                            Link(destination: URL(string: "https://github.com/JoneWang/imink/wiki/FAQ-zh_Hans")!) {
                                Text("点击了解更多...")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 14) {
                        Text("以上内容无法解决问题？")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        
                        Text("您还可以通过以下方式联系乌贼技术顾问：")
                            .font(.subheadline)
                        
                        HStack(spacing: 16) {
                            Link(destination: URL(string: "https://weibo.com/7582779251")!) {
                                VStack(spacing: 4) {
                                    Text("微博")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                    
                                    Text("@imink_splatoon")
                                        .font(.caption)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                                .background(Color.systemGray5)
                                .continuousCornerRadius(8)
                            }

                            if MailView.canSendMail() {
                                Button(action: {
                                    showingMailView = true
                                }) {
                                    VStack(spacing: 4) {
                                        Text("邮件")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                        
                                        Text("imink@jone.wang")
                                            .font(.caption)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(Color.systemGray5)
                                    .continuousCornerRadius(8)
                                }
                                .sheet(isPresented: $showingMailView) {
                                    MailView(isShowing: $showingMailView, recipient: "imink@jone.wang")
                                }
                            } else {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .foregroundColor(.secondaryLabel)
                }
                .padding(16)
            }
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
            .navigationTitle("常见登录问题FAQ")
        }
    }
}

struct LoginFAQPage_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { isPresented in
            Rectangle()
                .sheet(isPresented: isPresented, content: {
                    LoginFAQPage()
                        .preferredColorScheme(.light)
                })
        }
    }
}
