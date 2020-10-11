//
//  MeViewController.swift
//  imink
//
//  Created by Jone Wang on 2020/10/11.
//

import UIKit
import SwiftUI

class MeViewController: UIViewController {

    static let storyboardID = "Me"
    static func instantiateFromStoryboard() -> MeViewController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? MeViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureContentView()
    }
    
    func configureContentView() {
        let hostingController = UIHostingController(rootView: MePage())
        addChild(hostingController)
        
        view.addSubview(hostingController.view)
        hostingController.view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

}
