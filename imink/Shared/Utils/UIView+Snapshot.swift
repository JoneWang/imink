//
//  UIView+Snapshot.swift
//  imink
//
//  Created by Jone Wang on 2020/9/26.
//

import Foundation
import UIKit

extension UIView {
    
    func snapshot(of rect: CGRect? = nil, afterScreenUpdates: Bool = true) -> UIImage {
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: afterScreenUpdates)
        }
    }
    
}
