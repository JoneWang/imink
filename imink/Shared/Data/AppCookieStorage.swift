//
//  AppCookieStorage.swift
//  imink
//
//  Created by Jone Wang on 2021/6/11.
//

import Foundation

extension HTTPCookieStorage {
    static let appGroup: HTTPCookieStorage = {
        // CookieStorage migrator
        
        let oldCookieStorage = HTTPCookieStorage.shared
        let oldSessionCookie = oldCookieStorage.cookies?.first(where: { $0.name == "iksm_session" })
        
        let appGroupCookieStorage = HTTPCookieStorage
            .sharedCookieStorage(forGroupContainerIdentifier: "group.wang.jone.imink")
        let appGroupSessionCookie = appGroupCookieStorage.cookies?.first(where: { $0.name == "iksm_session" })
        
        if let oldSessionCookie = oldSessionCookie {
            oldCookieStorage.deleteCookie(oldSessionCookie)
            
            // to app group
            if appGroupSessionCookie == nil {
                appGroupCookieStorage.setCookie(oldSessionCookie)
            }
        }
        
        return appGroupCookieStorage
    }()
}
