//
//  TabBarController.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit

enum TabBarItem: Int, CaseIterable {
    case home, battleRecord
}

extension TabBarItem {
    
    func title() -> String {
        switch self {
        case .home:
            return "Home"
        case .battleRecord:
            return "Battle Records"
        }
    }
    
    func image() -> UIImage? {
        switch self {
        case .home:
            return UIImage(named: "TabbarBattleRecord")
        case .battleRecord:
            return UIImage(named: "TabbarBattleRecord")
        }
    }
    
}

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let items = tabBar.items {
//            for item in TabBarItem.allCases {
//                if traitCollection.userInterfaceIdiom == .phone {
//                    items[item.rawValue].title = item.title()
//                } else {
//                    items[item.rawValue].title = ""
//                }
//                items[item.rawValue].image = item.image()
//            }
//        }
    }
    
}
