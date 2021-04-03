//
//  NotificationName.swift
//  imink
//
//  Created by Jone Wang on 2020/9/25.
//

import Foundation

extension Notification.Name {
    
    static let showLoginView = NSNotification.Name("ShowLoginViewNSNotification")
    
    static let logout = NSNotification.Name("logout")
        
    static let isLoadingRealTimeBattleResult = NSNotification.Name("IsLoadingRealTimeBattleResultNotification")
        
    static let recordSyncDetailFinished = NSNotification.Name("RecordSyncDetailFinished")
    
}
