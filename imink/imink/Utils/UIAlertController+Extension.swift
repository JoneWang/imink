//
//  UIAlertController+Extension.swift
//  imink
//
//  Created by Jone Wang on 2021/4/3.
//

import Foundation
import UIKit

extension UIAlertController {
    
    static func show(title: String, message: String, buttonTitle: String = "OK", okAction: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default) { _ in
            alert.dismiss(animated: true)
            okAction?()
        })
        UIViewController.topmostController?.present(alert, animated: true)
    }
}
