//
//  NintendoAccountLoginViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/10/29.
//

import UIKit
import SwiftUI
import WebKit
import Combine
import SnapKit

struct NintendoAccountLoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()

    @State var navigationBarTitle: String?
    @State var loginFAQPresented = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isSimplifiedChinese {
                    LoginFAQButton()
                        .onTapGesture {
                            loginFAQPresented = true
                        }
                        .sheet(isPresented: $loginFAQPresented) {
                            LoginFAQPage()
                        }
                }
                
                ZStack {
                    NintendoAccountLoginWebView(
                        url: viewModel.loginUrl,
                        codeVerifier: viewModel.codeVerifier,
                        title: $navigationBarTitle,
                        selectAccount: { sessionTokenCode in
                            viewModel.loginFlow(sessionTokenCode: sessionTokenCode)
                        })
                        .edgesIgnoringSafeArea(.bottom)
                        .background(
                            viewModel.status == .loading ?
                                Color(.sRGB, white: 0.75, opacity: 1) :
                                Color(.sRGB, white: 0.95, opacity: 1)
                        )
                    
                    if viewModel.status == .loading {
                        Rectangle()
                            .foregroundColor(viewModel.loginProgress.count > 0 ? Color.secondarySystemBackground : Color.systemBackground)
                            .opacity(0.8)
                            .overlay(viewModel.loginProgress.count > 0 ? AnyView(EmptyView()) : AnyView(ProgressView().scaleEffect(1.5).padding(.bottom, 84)))
                            .colorScheme(.light)
                            .animation(.default)
                        
                        if viewModel.loginProgress.count > 0 {
                            VStack {
                                VStack {
                                    ForEach(0..<viewModel.loginProgress.count, id: \.self) { i in
                                        let progress = viewModel.loginProgress[i]
                                        HStack {
                                            Text(progress.api.name)
                                                .font(.system(size: 12))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 4)
                                                .padding(.vertical, 2)
                                                .background(progress.api.color)
                                                .continuousCornerRadius(4)
                                            
                                            Text(progress.path)
                                                .font(.system(size: 14))
                                                .foregroundColor(Color.secondaryLabel)
                                            
                                            Spacer()
                                            
                                            if progress.status == .loading {
                                                ProgressView()
                                            } else if progress.status == .success {
                                                Image(systemName: "checkmark.circle")
                                                    .foregroundColor(.green)
                                            } else if progress.status == .fail {
                                                Image(systemName: "xmark.circle")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                        .padding(8)
                                        .frame(width: 280, height: 30)
                                    }
                                    
                                    if let error = viewModel.loginError {
                                        if case NSOError.userGameDataNotExist = error {
                                            Text("user_game_data_not_exist_message")
                                                 .font(.system(size: 14))
                                                 .padding(.top, 16)
                                        } else {
                                            Text("login_error_message")
                                                 .font(.system(size: 14))
                                                 .padding(.top, 16)
                                        }
                                        
                                        HStack {
                                            Text("Close")
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 18)
                                        }
                                        .frame(width: 80, height: 30)
                                        .background(Color.accentColor)
                                        .continuousCornerRadius(8)
                                        .onTapGesture {
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.white)
                                .continuousCornerRadius(10)
                                .colorScheme(.light)
                                
                                Spacer()
                            }
                            .frame(height: 440)
                            .animation(.default)
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarTitle(navigationBarTitle ?? "Nintendo Account", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
                    .fontWeight(.regular)
            })
        }
        .onAppear {
            viewModel.status = .loading
        }
        .onChange(of: navigationBarTitle) { title in
            if title != "" {
                viewModel.status = .none
            }
        }
        .onChange(of: viewModel.status) { status in
            if status == .loginSuccess {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private var isSimplifiedChinese: Bool {
        AppUserDefaults.shared.currentLanguage == "zh-Hans"
    }
}

struct NintendoAccountLoginWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let url: URL
    let codeVerifier: String
    @Binding var title: String?
    let selectAccount: (String) -> Void
    
    final class Coordinator: NSObject, WKURLSchemeHandler {
        var cancelBag = Set<AnyCancellable>()
        let selectAccount: (String) -> Void
        
        init(selectAccount: @escaping (String) -> Void) {
            self.selectAccount = selectAccount
        }
        
        func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
            let jumpUrl = urlSchemeTask.request.url!.absoluteString
            
            guard let regex = try? NSRegularExpression(
                    pattern: "session_token_code=(.*)&",
                    options: []),
                  let match = regex.matches(
                    in: jumpUrl,
                    options: [],
                    range: NSRange(location: 0, length: jumpUrl.count)).first
            else {
                return
            }
            
            let sessionTokenCode = NSString(string: jumpUrl)
                .substring(with: match.range(at: 1))
            
            self.selectAccount(sessionTokenCode)
        }
        
        func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) { }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(selectAccount: selectAccount)
    }
    
    func makeUIView(context: Context) -> UIViewType {
        let webView = configureWebView(context: context)
        
        webView.publisher(for: \.title)
            .assign(to: \.title, on: self)
            .store(in: &context.coordinator.cancelBag)
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        coordinator.cancelBag.removeAll()
    }
}

extension NintendoAccountLoginWebView {
    func configureWebView(context: Context) -> UIViewType {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let processPool = WKProcessPool()

        let config = WKWebViewConfiguration()
        config.processPool = processPool
        config.setURLSchemeHandler(context.coordinator, forURLScheme: NSOAPI.clientUrlScheme)
        
        config.applicationNameForUserAgent = "imink"

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.allowsLinkPreview = false
        
        return webView
    }
}

extension LoginProgress.API {

}

struct NintendoAccountLoginView_Previews: PreviewProvider {
    static var previews: some View {
        StatefulPreviewWrapper(true) { showLoginView in
            Rectangle()
                .sheet(isPresented: showLoginView) {
                    NintendoAccountLoginView()
                }
        }
    }
}
