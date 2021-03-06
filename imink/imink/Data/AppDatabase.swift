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
                t.column("isDetail", .boolean).notNull().defaults(to: true)
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
        
        migrator.registerMigration("V2") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "killCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "assistCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "specialCount", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "gamePaintPoint", .integer).defaults(to: 0).notNull()
                tableAlteration.add(column: "syncDetailTime", .datetime)
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "killCount = :killCount, " +
                        "assistCount = :assistCount, " +
                        "specialCount = :specialCount, " +
                        "gamePaintPoint = :gamePaintPoint, " +
                        "syncDetailTime = :syncDetailTime " +
                        "WHERE id = :id",
                    arguments: [
                        "killCount": battle.playerResult.killCount,
                        "assistCount": battle.playerResult.assistCount,
                        "specialCount": battle.playerResult.specialCount,
                        "gamePaintPoint": battle.playerResult.gamePaintPoint,
                        "syncDetailTime": Date(),
                        "id": id
                    ])
            }
        }
        
        migrator.registerMigration("V3") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "gameModeKey", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "startDateTime", .datetime).defaults(to: Date()).notNull()
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "gameModeKey = :gameModeKey, " +
                        "startDateTime = :startDateTime " +
                        "WHERE id = :id",
                    arguments: [
                        "gameModeKey": battle.gameMode.key.rawValue,
                        "startDateTime": battle.startTime,
                        "id": id
                    ])
            }
        }
        
        migrator.registerMigration("V4") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "udemaeName", .text)
                tableAlteration.add(column: "udemaeSPlusNumber", .integer)
                tableAlteration.add(column: "type", .text).defaults(to: "").notNull()
                tableAlteration.add(column: "leaguePoint", .double)
                tableAlteration.add(column: "estimateGachiPower", .integer)
                tableAlteration.add(column: "playerTypeSpecies", .text).defaults(to: "").notNull()
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "udemaeName = ?, " +
                        "udemaeSPlusNumber = ?, " +
                        "type = ?, " +
                        "leaguePoint = ?, " +
                        "estimateGachiPower = ?, " +
                        "playerTypeSpecies = ? " +
                        "WHERE id = ?",
                    arguments: [
                        battle.udemae?.name,
                        battle.udemae?.sPlusNumber,
                        battle.type,
                        battle.leaguePoint,
                        battle.estimateGachiPower,
                        battle.playerResult.player.playerType.species,
                        id
                    ])
            }
        }
        
        migrator.registerMigration("V5") { db in
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "udemaeName = ?, " +
                        "udemaeSPlusNumber = ? " +
                        "WHERE id = ?",
                    arguments: [
                        battle.udemae?.name,
                        battle.udemae?.sPlusNumber,
                        id
                    ])
            }
        }
        
        migrator.registerMigration("V6") { db in
            try DBRecord.filter(DBRecord.Columns.isDetail == false)
                .deleteAll(db)
        }
        
        migrator.registerMigration("createJob") { db in
            try db.create(table: "job") { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("sp2PrincipalId", .text).notNull()
                t.column("jobId", .integer).notNull()
                t.column("json", .text).notNull()
                t.column("isClear", .boolean).notNull()
                t.column("gradePoint", .integer).notNull()
                t.column("gradePointDelta", .integer).notNull()
                t.column("gradeId", .text).notNull()
                t.column("helpCount", .integer).notNull()
                t.column("deadCount", .integer).notNull()
                t.column("goldenIkuraNum", .integer).notNull()
                t.column("ikuraNum", .integer).notNull()
                t.column("failureWave", .integer)
                t.column("dangerRate", .double).notNull()
            }
        }
        
        migrator.registerMigration("V7") { db in
            try db.alter(table: "record", body: { tableAlteration in
                tableAlteration.add(column: "weaponId", .text).defaults(to: "0").notNull()
            })
            
            try self.eachBattles(db: db) { (id, battle) in
                try db.execute(
                    sql: "UPDATE record SET " +
                        "weaponId = ? " +
                        "WHERE id = ?",
                    arguments: [
                        battle.playerResult.player.weapon.id,
                        id
                    ])
            }
        }
        
        return migrator
    }
}

extension AppDatabase {
    
    func eachBattles(db: Database, _ block: (Int64, Battle) throws -> Void) throws {
        let rows = try Row.fetchCursor(db, sql: "SELECT id, json FROM record")
        while let row = try? rows.next() {
            guard let id = row["id"] as? Int64,
                  let json = row["json"] as? String else {
                continue
            }
            
            guard let battle = json.decode(Battle.self) else {
                continue
            }
            
            try block(id, battle)
        }
    }
    
}
