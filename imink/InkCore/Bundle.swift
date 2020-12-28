//
//  Bundle.swift
//  InkCore
//
//  Created by Jone Wang on 2020/12/28.
//

import SwiftUI

public extension Bundle {
    
    static var inkCore: Bundle? {
        let path = Bundle.main.path(forResource: "InkCore", ofType: "framework", inDirectory: "Frameworks")!
        return Bundle(path: path)
    }
    
}
