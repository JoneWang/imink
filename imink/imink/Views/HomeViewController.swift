//
//  HomeViewController.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    static let storyboardID = "Home"
    static func instantiateFromStoryboard() -> HomeViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? HomeViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureContentView()
    }
    
    func configureContentView() {
        let hostingController = UIHostingController(rootView: HomePage())
        addChild(hostingController)
        
        view.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
