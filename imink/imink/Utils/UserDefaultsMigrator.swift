//
//  UserDefaultsMigrator.swift
//  imink
//
//  Created by Jone Wang on 2020/10/18.
//

import Foundation

final class UserDefaultsMigrator: NSObject {
    private let from: UserDefaults
    private let to: UserDefaults
    
    private var hasMigrated = false
    
    init(from: UserDefaults, to: UserDefaults) {
        self.from = from
        self.to = to
    }
    
    // Returns the proper defaults to be used by the application
    func defaults() -> UserDefaults {
        return to
    }
    
    func migrate() {
        // User Defaults - Old
        let userDefaults = from
        
        // App Groups Default - New
        let groupDefaults = to
        
        // Don't migrate if they are the same defaults!
        if userDefaults == groupDefaults {
            return
        }
        
        // Key to track if we migrated
        let didMigrateToAppGroups = "DidMigrateToAppGroups9"
        
        if !groupDefaults.bool(forKey: didMigrateToAppGroups) {
            
            // Doing this loop because in practice we might want to filter things (I did), instead of a straight migration
            for key in userDefaults.dictionaryRepresentation().keys {
                groupDefaults.set(userDefaults.dictionaryRepresentation()[key], forKey: key)
            }
            groupDefaults.set(true, forKey: didMigrateToAppGroups)
        }
    }
    
}
