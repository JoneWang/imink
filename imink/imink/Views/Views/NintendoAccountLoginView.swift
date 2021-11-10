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
                            .foregroundColor(Color.systemBackground)
                            .opacity(0.8)
                            .overlay(ProgressView().scaleEffect(1.5).padding(.bottom, 84))
                            .colorScheme(.light)
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
        .onReceive(viewModel.$loginError) { error in
            guard let error = error else { return }
            if case NSOError.userGameDataNotExist = error {
                UIAlertController.show(
                    title: "login_error_title".localized,
                    message: "user_game_data_not_exist_message".localized
                ) {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                UIAlertController.show(
                    title: "login_error_title".localized,
                    message: "login_error_message".localized
                ) {
                    presentationMode.wrappedValue.dismiss()
                }
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
