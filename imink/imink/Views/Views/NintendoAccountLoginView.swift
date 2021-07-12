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

struct NintendoAccountLoginView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    
    let viewModel = LoginViewModel()
        
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
        loadingView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
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
    
    let hideHeader = "var h = document.getElementsByClassName(\"c-header\")[0];h.setAttribute(\"style\", \"visibility: hidden;\");h.parentElement.setAttribute(\"style\", \"height: 0px;\");"
    let hideFooter = "var h = document.getElementsByClassName(\"c-footer\")[0];h.setAttribute(\"style\", \"visibility: hidden;\");h.parentElement.setAttribute(\"style\", \"height: 0px;\");"
    let hideForgotPassword = "document.getElementsByClassName(\"LoginForm_forgotPassword\")[0].setAttribute(\"style\", \"visibility: hidden;\");"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebView()
        
        viewModel.status = .loading
        
        let (url, codeVerifier) = authorizeInfo()
        let request = URLRequest(url: url)
        
        viewModel.codeVerifier = codeVerifier

        webView.load(request)
        
        viewModel.$loginError
            .sink { [weak self] error in
                guard let error = error, let `self` = self else { return }
                if case NSOError.userGameDataNotExist = error {
                    UIAlertController.show(
                        title: "login_error_title".localized,
                        message: "user_game_data_not_exist_message".localized
                    ) {
                        self.dismiss(animated: true)
                    }
                } else {
                    UIAlertController.show(
                        title: "login_error_title".localized,
                        message: "login_error_message".localized
                    ) {
                        self.dismiss(animated: true)
                    }
                }
            }
            .store(in: &cancelBag)
        
        viewModel.$status
            .sink { [weak self] status in
                if status == .loginSuccess {
                    NotificationCenter.default.post(name: .loginedSuccessed, object: nil)
                    self?.dismiss(animated: true)
                }
                
                self?.loadingView.isHidden = status != .loading
            }
            .store(in: &cancelBag)
        
        Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { _ in
                self.webView.evaluateJavaScript(self.hideHeader, completionHandler: nil)
                self.webView.evaluateJavaScript(self.hideFooter, completionHandler: nil)
                self.webView.evaluateJavaScript(self.hideForgotPassword, completionHandler: nil)
            }
            .store(in: &cancelBag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        viewModel.loginError = nil
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
        
        view.insertSubview(webView, belowSubview: loadingView)
        webView.snp.makeConstraints { (make) -> Void in
            make.left.right.equalTo(view)
            make.top.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        webView.publisher(for: \.title)
            .sink { [weak self] title in
                self?.viewModel.status = .none
                self?.navigationItem.title = title
            }
            .store(in: &cancelBag)
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
