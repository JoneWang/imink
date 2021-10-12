//
//  SystemInfo.swift
//  imink
//
//  Created by Jone Wang on 2021/10/12.
//

import Foundation

struct SystemInfo {
    static var iOS15: Bool {
        if #available(iOS 15.0, *) {
            return true
        } else {
            return false
        }
    }
}
