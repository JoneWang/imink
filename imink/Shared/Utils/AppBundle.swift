//
//  AppBundle.swift
//  imink
//
//  Created by Jone Wang on 2020/9/3.
//

import Foundation

struct AppBundle {
    static let name: String =
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "?"
    
    static let version: String =
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    
    static let build: String =
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
}
