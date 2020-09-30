//
//  SplitViewDelegate.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit

class SplitViewDelegate: NSObject, UISplitViewControllerDelegate {
    
    func splitViewController(_ splitViewController: UISplitViewController, showDetail vc: UIViewController, sender: Any?) -> Bool {
        guard
            splitViewController.isCollapsed == true,
            let tabBarController = splitViewController.viewControllers.first as? UITabBarController,
            let navigationController = tabBarController.selectedViewController as? UINavigationController
        else { return false }
       
        var viewControllerToPush = vc
        if let otherNavigationController = vc as? UINavigationController {
            if let topViewController = otherNavigationController.topViewController {
                viewControllerToPush = topViewController
            }
        }
        viewControllerToPush.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewControllerToPush, animated: true)
        
        return true
    }
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        NotificationCenter.default.post(
            name: .splitVCDisplayMode,
            object: displayMode
        )
    }
    
}
