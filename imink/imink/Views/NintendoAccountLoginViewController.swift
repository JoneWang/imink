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

struct NintendoAccountLoginPage: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    
    let viewModel: LoginViewModel
        
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = NintendoAccountLoginViewController()
        vc.viewModel = viewModel
        return UINavigationController(rootViewController: vc)
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
}

class NintendoAccountLoginViewController: UIViewController, WKUIDelegate {
    
    var viewModel: LoginViewModel!
    
    private var cancelBag = Set<AnyCancellable>()
    private var webView: WKWebView!
    
    lazy var loadingView: UIView = {
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = false
        loadingView.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints {
            $0.center.equalTo(loadingView)
        }
        
        activityIndicator.startAnimating()
        
        return loadingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebView()
        
        viewModel.isLoading = true
        
        let (url, codeVerifier) = authorizeInfo()
        let request = URLRequest(url: url)
        
        viewModel.codeVerifier = codeVerifier

        webView.load(request)
        
        viewModel.$isLoading
            .map { !$0 }
            .assign(to: \.isHidden, on: loadingView)
            .store(in: &cancelBag)
        
        viewModel.$status
            .filter { $0 == .loginFail }
            .sink { [weak self] _ in
                let alert = UIAlertController(
                    title: "Failure".localized,
                    message: "Login error occurred, please try again.".localized,
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    alert.dismiss(animated: true) {
                        self?.dismiss(animated: true)
                    }
                })
                self?.present(alert, animated: true)
            }
            .store(in: &cancelBag)
        
        NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] _ in
                self?.scrollToTop()
            }
            .store(in: &cancelBag)
    }
    
    func configureWebView() {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let processPool = WKProcessPool()

        let config = WKWebViewConfiguration()
        config.processPool = processPool
        
        config.setURLSchemeHandler(LoginSchemeHandler(start: { [weak self] request in
            let jumpUrl = request.url!.absoluteString
            
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
            
            self?.viewModel.loginFlow(sessionTokenCode: sessionTokenCode)
        }), forURLScheme: NSOAPI.clientUrlScheme)
        
        config.applicationNameForUserAgent = "imink"

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.allowsLinkPreview = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        view.insertSubview(webView, belowSubview: loadingView)
        webView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        webView.publisher(for: \.title)
            .sink { [weak self] title in
                self?.viewModel.isLoading = false
                self?.navigationItem.title = title
                
                self?.scrollToTop()
            }
            .store(in: &cancelBag)
        
        webView.navigationDelegate = self
    }

}

class LoginSchemeHandler: NSObject, WKURLSchemeHandler {
    
    var start: (URLRequest) -> Void
    
    init(start: @escaping (URLRequest) -> Void) {
        self.start = start
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        start(urlSchemeTask.request)
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {

    }
    
}

extension NintendoAccountLoginViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.perform(#selector(scrollToTop), with: nil, afterDelay: 0.5)
    }
}

extension NintendoAccountLoginViewController {
    
    func authorizeInfo() -> (URL, String) {
        let codeVerifier = NSOHash.urandom(length: 32).base64EncodedString
        let authorizeAPI = NSOAPI.authorize(codeVerifier: codeVerifier)
        
        let url = authorizeAPI.baseURL.appendingPathComponent(authorizeAPI.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        if let querys = authorizeAPI.querys {
            let queryItems = querys.map { name, value in
                URLQueryItem(name: name, value: value)
            }
            urlComponents.queryItems = queryItems
        }
        
        return (urlComponents.url!, codeVerifier)
    }
}

extension NintendoAccountLoginViewController {
    
    @objc func scrollToTop() {
        self.webView
            .scrollView
            .setContentOffset(
                .init(x: 0, y: 0),
                animated: true
            )
    }
}
