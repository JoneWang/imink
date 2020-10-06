//
//  HomeNavigationController.swift
//  imink
//
//  Created by 王强 on 2020/10/6.
//

import UIKit

class HomeNavigationController: UINavigationController {
    
    static let storyboardID = "HomeNav"
    static func instantiateFromStoryboard() -> HomeNavigationController? {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        return storyboard.instantiateViewController(identifier: storyboardID) as? HomeNavigationController
    }

}
