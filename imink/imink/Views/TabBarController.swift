//
//  TabBarController.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import Combine
import SwiftUI

class TabBarController: UITabBarController {
    
    private var loginViewController: UIHostingController<LoginPage>?
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var tabBarViewModel: TabBarViewModel!
    private var loginPageViewModel: LoginViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarViewModel = TabBarViewModel()
        
        NotificationCenter.default
            .publisher(for: .logout)
            .receive(on: RunLoop.main)
            .map { _ in false }
            .assign(to: &tabBarViewModel.$isLogin)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tabBarViewModel.$isLogin
            .sink { [weak self] isLogin in
                if isLogin {
                    self?.setupItems()
                } else {
                    self?.showLogin()
                }
            }
            .store(in: &cancelBag)
    }
    
    func setupItems() {
        guard let homeViewController = HomeViewController.instantiateFromStoryboard(),
              let battleSplitViewController = BattleSplitViewController.instantiateFromStoryboard(),
              let meViewController = MeViewController.instantiateFromStoryboard() else {
            return
        }
        
        viewControllers = [homeViewController, battleSplitViewController, meViewController]
    }
    
    func showLogin() {
        viewControllers = []
        
        let viewModel = LoginViewModel()
        
        let loginPage = LoginPage(launchPageViewModel: viewModel)
        let loginViewController = UIHostingController(rootView: loginPage)
        loginViewController.modalPresentationStyle = .formSheet
        loginViewController.preferredContentSize = .init(width: 400, height: 250)
        
        viewModel.$status
            .filter { $0 == .loginSuccess }
            .sink { [weak self] _ in
                self?.tabBarViewModel.isLogin = true
                self?.loginViewController?.dismiss(animated: true)
            }
            .store(in: &viewModel.cancelBag)
        
        self.loginViewController = loginViewController
        
        present(loginViewController, animated: true) {
            // Disable dismiss gesture
            loginViewController
                .presentationController?
                .presentedView?
                .gestureRecognizers?[0]
                .isEnabled = false
        }
    }
    
}
