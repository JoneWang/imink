//
//  UIViewController+Extension.swift
//  imink
//
//  Created by Jone Wang on 2021/5/31.
//

import Foundation
import UIKit

extension UIViewController {
    
    static var topmostController: UIViewController? {
        if var topController = UIApplication.shared.windows.first?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
