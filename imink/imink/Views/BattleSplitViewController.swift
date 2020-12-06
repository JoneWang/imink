//
//  BattleSplitViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/10/1.
//

import UIKit

class BattleSplitViewController: UISplitViewController {
    
    static let storyboardID = "BattleSplit"
    static func instantiateFromStoryboard() -> BattleSplitViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? BattleSplitViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        primaryBackgroundStyle = .sidebar
    }
    
}

extension BattleSplitViewController: UISplitViewControllerDelegate {
    
    func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        NotificationCenter.default.post(
            name: .splitVCDisplayMode,
            object: displayMode
        )
    }
    
}
