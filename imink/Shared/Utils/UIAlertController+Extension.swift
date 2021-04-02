//
//  UIAlertController+Extension.swift
//  imink
//
//  Created by Jone Wang on 2021/4/3.
//

import Foundation
import UIKit

extension UIAlertController {
    
    static func show(with vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alert.dismiss(animated: true)
        })
        vc.present(alert, animated: true)
    }
}
