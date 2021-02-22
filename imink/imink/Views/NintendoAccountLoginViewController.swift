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

var myContext = 0

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

        viewModel.$loginInfo
            .sink { [weak self] loginInfo in
                if let loginInfo = loginInfo {
                    self?.webView.load(URLRequest(url: URL(string: loginInfo.loginUrl)!))
                }
            }
            .store(in: &cancelBag)
        
        viewModel.$isLoading
            .map { !$0 }
            .assign(to: \.isHidden, on: loadingView)
            .store(in: &cancelBag)
    }
    
    func configureWebView() {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true

        let processPool = WKProcessPool()

        let config = WKWebViewConfiguration()
        config.processPool = processPool
        
        config.setURLSchemeHandler(LoginSchemeHandler(start: { [weak self] request in
            self?.viewModel.signIn(request.url!.absoluteString)
                .sink { [weak self] completion in
                    switch completion {
                    case .failure(_):
                        let alert = UIAlertController(title: "Failure".localized, message: "Login error occurred, please try again.".localized, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            alert.dismiss(animated: true) {
                                self?.dismiss(animated: true)
                            }
                        })
                        self?.present(alert, animated: true)
                    case .finished:
                        break
                    }
                } receiveValue: { _ in
                }
                .store(in: &self!.viewModel.cancelBag)
        }), forURLScheme: "npf71b963c1b7b6d119")
        
        config.applicationNameForUserAgent = "imink"

        webView = WKWebView(frame: view.bounds, configuration: config)
        
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
