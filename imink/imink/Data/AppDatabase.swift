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
        #if DEBUG
//        migrator.eraseDatabaseOnSchemaChange = true
        #endif
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
                t.column("gameModeKey", .text).notNull()
                t.column("stageName", .text).notNull()
                t.column("killTotalCount", .integer).notNull()
                t.column("deathCount", .integer).notNull()
                t.column("myPoint", .double).notNull()
                t.column("otherPoint", .double).notNull()
            }
        }
        
        migrator.registerMigration("V2") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "killCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "assistCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "specialCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "gamePaintPoint", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "syncDetailTime", .datetime)
            })
            
            let records = try Record.fetchAll(db)
            for record in records {
                var record = record
                
                let battle = record.battle
                record.killCount = battle?.playerResult.killCount ?? 0
                record.assistCount = battle?.playerResult.assistCount ?? 0
                record.specialCount = battle?.playerResult.specialCount ?? 0
                record.gamePaintPoint = battle?.playerResult.gamePaintPoint ?? 0
                
                record.syncDetailTime = Date()
                
                try record.update(db)
            }
        }
        
        migrator.registerMigration("V3") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "gameModeKey", .text).defaults(to: "").notNull()
            })
            
            let records = try Record.fetchAll(db)
            for record in records {
                var record = record
                
                if let battle = record.battle {
                    record.gameModeKey = battle.gameMode.key.rawValue
                }
                
                try record.update(db)
            }
        }
        
        return migrator
    }
}

