//
//  AppDatabase.swift
//  imink
//
//  Created by Jone Wang on 2020/9/14.
//

import Foundation
import Combine
import GRDB

class AppDatabase {
    static let shared = try! AppDatabase()
    
    internal let dbQueue: DatabaseQueue
    
    init() throws {
        let databaseURL = try FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("db.sqlite")
        
        #if DEBUG
        print("sqlite url: \(databaseURL.path)")
        #endif
        
        let dbQueue = try DatabaseQueue(path: databaseURL.path)
        
        self.dbQueue = dbQueue
        
        try migrator.migrate(dbQueue)
    }
    
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        migrator.eraseDatabaseOnSchemaChange = true
        migrator.registerMigration("createRecord") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "record") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("sp2PrincipalId", .text).notNull()
                t.column("battleNumber", .text).notNull()
                t.column("json", .text).notNull()
                t.column("isDetail", .boolean).notNull()
                t.column("victory", .boolean).notNull()
                t.column("weaponImage", .text).notNull()
                t.column("rule", .text).notNull()
                t.column("gameMode", .text).notNull()
                t.column("stageName", .text).notNull()
                t.column("killTotalCount", .integer).notNull()
                t.column("deathCount", .integer).notNull()
                t.column("myPoint", .double).notNull()
                t.column("otherPoint", .double).notNull()
            }
        }
        
        return migrator
    }
}

