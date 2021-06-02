//
//  SceneDelegate.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit
import Zip

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var toolbarDelegate = ToolbarDelegate()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        configureTabBarViewController()
        
        #if targetEnvironment(macCatalyst)
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let toolbar = NSToolbar(identifier: "main")
        toolbar.delegate = toolbarDelegate
        toolbar.displayMode = .iconOnly
        
        if let titlebar = windowScene.titlebar {
            titlebar.toolbar = toolbar
            titlebar.toolbarStyle = .automatic
        }
        #endif
    }
    
    func configureTabBarViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let tabBarController = storyboard.instantiateViewController(identifier: "TabBar") as? TabBarController else {
            fatalError()
        }
        
        window?.rootViewController = tabBarController
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url, url.isFileURL {
            DataBackup.import(url: url)
        }
    }
}
