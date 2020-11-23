//
//  DBRecord.swift
//  imink
//
//  Created by Jone Wang on 2020/9/14.
//

import Foundation
import GRDB
import Combine
import os

struct DBRecord: Identifiable {
    
    // MARK: Column
    
    var id: Int64?
    var sp2PrincipalId: String?
    var battleNumber: String
    var json: String
    
    // If the json from /results/<id> then isDetail is ture.
    var isDetail: Bool
    
    // List item information
    var victory: Bool
    var weaponImage: URL?
    var rule: String
    var gameMode: String
    var gameModeKey: String
    var stageName: String
    var killTotalCount: Int
    var killCount: Int
    var assistCount: Int
    var specialCount: Int
    var gamePaintPoint: Int
    var deathCount: Int
    var myPoint: Double
    var otherPoint: Double
    var syncDetailTime: Date?
    var startDateTime: Date
}

extension DBRecord: Codable, FetchableRecord, MutablePersistableRecord {
    
    // Table name
    static let databaseTableName = "record"
    
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let sp2PrincipalId = Column(CodingKeys.sp2PrincipalId)
        static let battleNumber = Column(CodingKeys.battleNumber)
        static let json = Column(CodingKeys.json)
        static let isDetail = Column(CodingKeys.isDetail)
        static let victory = Column(CodingKeys.victory)
        static let weaponImage = Column(CodingKeys.weaponImage)
        static let rule = Column(CodingKeys.rule)
        static let gameMode = Column(CodingKeys.gameMode)
        static let gameModeKey = Column(CodingKeys.gameModeKey)
        static let stageName = Column(CodingKeys.stageName)
        static let killTotalCount = Column(CodingKeys.killTotalCount)
        static let killCount = Column(CodingKeys.killCount)
        static let assistCount = Column(CodingKeys.assistCount)
        static let specialCount = Column(CodingKeys.specialCount)
        static let gamePaintPoint = Column(CodingKeys.gamePaintPoint)
        static let deathCount = Column(CodingKeys.deathCount)
        static let myPoint = Column(CodingKeys.myPoint)
        static let otherPoint = Column(CodingKeys.otherPoint)
        static let syncDetailTime = Column(CodingKeys.syncDetailTime)
        static let startDateTime = Column(CodingKeys.startDateTime)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == DBRecord { }

extension DBRecord: Hashable {
    static func == (lhs: DBRecord, rhs: DBRecord) -> Bool {
        lhs.id == rhs.id && lhs.json == rhs.json
    }
}

extension AppDatabase {
    
    // MARK: Writes
    
    /// Save a full battle record, from /results/<id>
    func saveDetail(_ battleObject: Dictionary<String, AnyObject>) throws {
        dbQueue.asyncWrite { db in
            guard let currentUser = AppUserDefaults.shared.user else {
                return
            }
            
            guard let battleNumber = battleObject["battle_number"] as? String else {
                return
            }
            
            guard let data = try? JSONSerialization.data(
                withJSONObject: battleObject,
                options: .sortedKeys
            ) else {
                return
            }
            
            guard let battleJson = String(data: data, encoding: .utf8) else {
                return
            }
            
            if var record = try DBRecord.filter(
                DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                    DBRecord.Columns.battleNumber == battleNumber
            ).fetchOne(db) {
                record.json = battleJson
                record.isDetail = true
                record.syncDetailTime = Date()
                try record.update(db)
            }
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveFullBattle] \(error.localizedDescription)")
            }
        }
    }
    
    /// Save data from /results
    func saveSampleBattlesData(_ data: Data, completed: @escaping (_ haveNewRecord: Bool) -> Void) throws {
        guard let currentUser = AppUserDefaults.shared.user else {
            return
        }
        
        guard let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
        ) as? [String: AnyObject],
        let results = json["results"] as? [Dictionary<String, AnyObject>] else {
            return
        }
        
        dbQueue.asyncWrite { db in
            
            var records = [DBRecord]()
            for index in results.indices {
                guard let data = try? JSONSerialization.data(withJSONObject: results[index], options: .sortedKeys),
                      let jsonString = String(data: data, encoding: .utf8) else {
                    continue
                }
                
                guard let battle = jsonString.decode(Battle.self) else {
                    continue
                }
                
                records.append(
                    DBRecord(
                        sp2PrincipalId: currentUser.sp2PrincipalId,
                        battleNumber: battle.battleNumber,
                        json: jsonString,
                        isDetail: false,
                        victory: battle.myTeamResult.key == .victory,
                        weaponImage: battle.playerResult.player.weapon.image,
                        rule: battle.rule.name,
                        gameMode: battle.gameMode.name,
                        gameModeKey: battle.gameMode.key.rawValue,
                        stageName: battle.stage.name,
                        killTotalCount: battle.playerResult.killCount + battle.playerResult.assistCount,
                        killCount: battle.playerResult.killCount,
                        assistCount: battle.playerResult.assistCount,
                        specialCount: battle.playerResult.specialCount,
                        gamePaintPoint: battle.playerResult.gamePaintPoint,
                        deathCount: battle.playerResult.deathCount,
                        myPoint: battle.myPoint,
                        otherPoint: battle.otherPoint,
                        startDateTime: battle.startTime)
                )
            }
            
            let battleNumbers = records.map { $0.battleNumber }
            
            let existRecords = try DBRecord.filter(
                DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                    battleNumbers.contains(DBRecord.Columns.battleNumber)
            ).fetchAll(db)
            
            let existBattleNumbers = existRecords.map { $0.battleNumber }
            
            let nonexistentRecords = records.filter {
                !existBattleNumbers.contains($0.battleNumber)
            }
            
            if nonexistentRecords.count > 0 {
                for record in nonexistentRecords.reversed() {
                    var record = record
                    try record.insert(db)
                }
                DispatchQueue.main.async {
                    completed(true)
                }
            } else {
                DispatchQueue.main.async {
                    completed(false)
                }
            }
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveSampleBattles] \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Reads
    
    func records() -> AnyPublisher<[DBRecord], Error> {
        guard let currentUser = AppUserDefaults.shared.user else {
            return Just<[DBRecord]>([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(
                DBRecord
                    .filter(DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId)
                    .order(DBRecord.Columns.battleNumber.desc)
                    .fetchAll
            )
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func totalCount() -> AnyPublisher<Int, Error> {
        guard let currentUser = AppUserDefaults.shared.user else {
            return Just<Int>(0)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(
                DBRecord
                    .filter(DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId)
                    .fetchCount
            )
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func totalKillCount() -> Int {
        guard let currentUser = AppUserDefaults.shared.user else {
            return 0
        }
        
        return dbQueue.read { db in
            let request = DBRecord.filter(
                DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId
            )
            .select(sum(DBRecord.Columns.killCount))
            return try! Int.fetchOne(db, request) ?? 0
        }
    }
    
    func vdWithLast500() -> [Bool] {
        guard let currentUser = AppUserDefaults.shared.user else {
            return []
        }
        
        return dbQueue.read { db in
            return try! Bool.fetchAll(
                db,
                sql: "SELECT victory FROM record WHERE sp2PrincipalId = ? ORDER BY startDateTime DESC LIMIT 0, 500",
                arguments: [currentUser.sp2PrincipalId]
            )
        }
    }
    
    func totalKD() -> Int {
        guard let currentUser = AppUserDefaults.shared.user else {
            return 0
        }
        
        return dbQueue.read { db in
            let request = DBRecord.filter(
                DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId
            )
            .select(sum(DBRecord.Columns.killCount))
            return try! Int.fetchOne(db, request) ?? 0
        }
    }
    
    func currentSyncTotalCount(lastSyncTime: Date) -> AnyPublisher<Int, Error> {
        guard let currentUser = AppUserDefaults.shared.user else {
            return Just<Int>(0)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(
                DBRecord.filter(
                (DBRecord.Columns.syncDetailTime == nil || (DBRecord.Columns.syncDetailTime != nil &&
                                                            DBRecord.Columns.syncDetailTime > lastSyncTime)) &&
                    DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId
            ).fetchCount)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func currentSynchronizedCount(lastSyncTime: Date) -> AnyPublisher<Int, Error> {
        guard let currentUser = AppUserDefaults.shared.user else {
            return Just<Int>(0)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(DBRecord.filter(
                DBRecord.Columns.isDetail &&
                    DBRecord.Columns.syncDetailTime > lastSyncTime &&
                    DBRecord.Columns.sp2PrincipalId == currentUser.sp2PrincipalId
            ).fetchCount)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func victoryAndDefeatCount(startTime: Date, endTime: Date = Date()) -> (Int, Int) {
        guard let currentUser = AppUserDefaults.shared.user else {
            return (0, 0)
        }
        
        return dbQueue.read { db in
            guard let victoryCount = try? Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM record WHERE victory AND startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, currentUser.sp2PrincipalId]
            ),
            let defeatCount = try? Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM record WHERE NOT victory AND startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, currentUser.sp2PrincipalId]
            ) else {
                return (0, 0)
            }
            
            return (victoryCount, defeatCount)
        }
    }
    
    func killAssistAndDeathCount(startTime: Date, endTime: Date = Date()) -> (Int, Int, Int) {
        guard let currentUser = AppUserDefaults.shared.user else {
            return (0, 0, 0)
        }
        
        return dbQueue.read { db in
            guard let killCount = try? Int.fetchOne(
                db,
                sql: "SELECT SUM(killCount) FROM record WHERE startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, currentUser.sp2PrincipalId]
            ),
            let assistCount = try? Int.fetchOne(
                db,
                sql: "SELECT SUM(assistCount) FROM record WHERE startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, currentUser.sp2PrincipalId]
            ),
            let deathCount = try? Int.fetchOne(
                db,
                sql: "SELECT SUM(deathCount) FROM record WHERE startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, currentUser.sp2PrincipalId]
            ) else {
                return (0, 0, 0)
            }
            
            return (killCount, assistCount, deathCount)
        }
    }
}

extension DBRecord {
    func copy(with zone: NSZone? = nil) -> DBRecord {
        let copy = DBRecord(
            id: id,
            sp2PrincipalId: sp2PrincipalId,
            battleNumber: battleNumber,
            json: json,
            isDetail: isDetail,
            victory: victory,
            weaponImage: weaponImage,
            rule: rule,
            gameMode: gameMode,
            gameModeKey: gameModeKey,
            stageName: stageName,
            killTotalCount: killTotalCount,
            killCount: killCount,
            assistCount: assistCount,
            specialCount: specialCount,
            gamePaintPoint: gamePaintPoint,
            deathCount: deathCount,
            myPoint: myPoint,
            otherPoint: otherPoint,
            startDateTime: startDateTime
        )
        return copy
    }
}

extension DBRecord {
    
    var battle: Battle? {
        json.decode(Battle.self)
    }
}
