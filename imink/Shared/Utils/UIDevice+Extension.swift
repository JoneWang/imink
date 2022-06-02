//
//  UIDevice+Extension.swift
//  imink
//
//  Created by Jone Wang on 2022/3/5.
//

import UIKit

@available(iOSApplicationExtension, unavailable)
extension UIDevice {
    var hasTopNotch: Bool {
        UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
    }
}
