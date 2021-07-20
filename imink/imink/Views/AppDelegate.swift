//
//  SceneDelegate.swift
//  imink
//
//  Created by Jone Wang on 2021/7/20.
//

import SwiftUI

@main
class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let windowScene = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }.first
        if let windowScene = windowScene as? UIWindowScene {
            let controller = UIHostingController(rootView: InkApp())

            window = UIWindow(windowScene: windowScene)
            window?.rootViewController = controller
            window?.makeKeyAndVisible()
        }

        return true
    }
}
