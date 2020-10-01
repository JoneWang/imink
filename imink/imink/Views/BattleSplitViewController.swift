//
//  BattleSplitViewController.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import UIKit

class BattleSplitViewController: UISplitViewController {
    
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
