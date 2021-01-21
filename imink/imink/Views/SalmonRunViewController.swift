//
//  SalmonRunViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/10/19.
//

import UIKit
import SwiftUI

class SalmonRunViewController: UIViewController {
    
    static let storyboardID = "SalmonRun"
    static func instantiateFromStoryboard() -> SalmonRunViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? SalmonRunViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureContentView()
    }
    
    func configureContentView() {
        let hostingController = UIHostingController(rootView: JobListPage())
        addChild(hostingController)
        
        view.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
