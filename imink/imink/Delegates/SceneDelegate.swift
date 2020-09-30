//
//  SceneDelegate.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var splitViewDelegate = SplitViewDelegate()
    var toolbarDelegate = ToolbarDelegate()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = IKWindow(windowScene: windowScene)
            self.window = window
            window.makeKeyAndVisible()
        }
        
        if window?.traitCollection.horizontalSizeClass == .compact {
            configureTwoColumnSplitViewController()
        } else {
            configureThreeColumnSplitViewController()
        }
        
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

    func configureThreeColumnSplitViewController() {
        guard let splitViewController = createThreeColumnSplitViewController() else {
            fatalError()
        }
        
        window?.rootViewController = splitViewController
        splitViewController.delegate = splitViewDelegate
    }
    
    func configureTwoColumnSplitViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        guard let splitViewController = storyboard.instantiateViewController(identifier: "TwoColumnSplit") as? UISplitViewController else {
            fatalError()
        }
        
        window?.rootViewController = splitViewController
        splitViewController.delegate = splitViewDelegate
    }

}

extension SceneDelegate {
    
    private func createThreeColumnSplitViewController() -> UISplitViewController? {
        guard
            let battleRecordListViewController = BattleRecordListViewController.instantiateFromStoryboard(),
            let battleDetailViewController = BattleDetailViewController.instantiateFromStoryboard()
        else { return nil }
        
        let sidebarViewController = SidebarViewController()
        
        // Configure the split view controller.
        let splitViewController = UISplitViewController(style: .tripleColumn)
        splitViewController.primaryBackgroundStyle = .sidebar
        splitViewController.preferredDisplayMode = .twoDisplaceSecondary
        
        // Add view controllers to the split view controller.
        splitViewController.setViewController(sidebarViewController, for: .primary)
        splitViewController.setViewController(battleRecordListViewController, for: .supplementary)
        splitViewController.setViewController(battleDetailViewController, for: .secondary)
        
        // Hide sidebar by default
//        splitViewController.hide(.supplementary)
        
        // Default width
        #if targetEnvironment(macCatalyst)
        #else
        if window?.traitCollection.userInterfaceIdiom != .pad {
            splitViewController.preferredSupplementaryColumnWidth = 280
        }
        #endif
        
        return splitViewController
    }
    
}

class IKWindow: UIWindow {
    
    /// Auto switch tabbar or split mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate
        else {
            return
        }
        
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            if traitCollection.horizontalSizeClass == .compact {
                sceneDelegate.configureTwoColumnSplitViewController()
            } else {
                sceneDelegate.configureThreeColumnSplitViewController()
            }
        }
    }
    
}
