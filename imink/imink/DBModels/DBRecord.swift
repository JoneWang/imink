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
    var json: String?
    
    @available(*, deprecated, message: "deprecated")
    var isDetail: Bool = true
    
    // List item information
    var victory: Bool
    var weaponId: String
    var weaponImage: String
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
    var udemaeName: String?
    var udemaeSPlusNumber: Int?
    var type: Battle.BattleType
    var leaguePoint: Double?
    var estimateGachiPower: Int?
    var playerTypeSpecies: Player.PlayerType.Species
    var isX: Bool
    var xPower: Double?
}

extension Battle.BattleType: DatabaseValueConvertible { }
extension Player.PlayerType.Species: DatabaseValueConvertible { }

extension DBRecord: Codable, FetchableRecord, MutablePersistableRecord {
    
    // Table name
    static let databaseTableName = "record"
    
    // Define database columns from CodingKeys
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let sp2PrincipalId = Column(CodingKeys.sp2PrincipalId)
        static let battleNumber = Column(CodingKeys.battleNumber)
        static let json = Column(CodingKeys.json)
        static let isDetail = Column(CodingKeys.isDetail)
        static let victory = Column(CodingKeys.victory)
        static let weaponId = Column(CodingKeys.weaponId)
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
    
    func saveBattle(data: Data) {
        dbQueue.asyncWrite { db in
            try self.saveBattle(db: db, data: data)
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveBattle] \(error.localizedDescription)")
            }
        }
    }
    
    func saveBattles(datas: [Data]) {
        dbQueue.asyncWrite { db in
            for data in datas {
                try self.saveBattle(db: db, data: data)
            }
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveBattles] \(error.localizedDescription)")
            }
        }
    }
    
    private func saveBattle(db: Database, data: Data) throws {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId,
              let jsonString = String(data: data, encoding: .utf8),
              let battle = jsonString.decode(Battle.self) else {
            return
        }
        
        if try DBRecord.filter(
            DBRecord.Columns.sp2PrincipalId == sp2PrincipalId &&
                DBRecord.Columns.battleNumber == battle.battleNumber
        ).fetchCount(db) > 0 {
            return
        }
        
        var record = DBRecord(
            sp2PrincipalId: sp2PrincipalId,
            battleNumber: battle.battleNumber,
            json: jsonString,
            victory: battle.myTeamResult.key == .victory,
            weaponId: battle.playerResult.player.weapon.id,
            weaponImage: battle.playerResult.player.weapon.$image,
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
            startDateTime: battle.startTime,
            udemaeName: battle.udemae?.name,
            udemaeSPlusNumber: battle.udemae?.sPlusNumber,
            type: battle.type,
            leaguePoint: battle.leaguePoint,
            estimateGachiPower: battle.estimateGachiPower,
            playerTypeSpecies: battle.playerResult.player.playerType.species,
            isX: battle.udemae?.isX ?? false,
            xPower: battle.xPower)
        try record.insert(db)
    }
    
    func removeAllRecords() {
        dbQueue.asyncWrite { db in
            try DBRecord.deleteAll(db)
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveBattle] \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Reads
    
    func unsynchronizedBattleIds(with battleIds: [String]) -> [String] {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return []
        }
        
        return try! dbQueue.read { db in
            let alreadyExistsRecords = try! DBRecord.filter(
                DBRecord.Columns.sp2PrincipalId == sp2PrincipalId &&
                battleIds.contains(DBRecord.Columns.battleNumber)
            )
            .fetchAll(db)
            
            let alreadyExistsIds = alreadyExistsRecords.map { $0.battleNumber }
            let unsynchronizedIds = Array(Set(battleIds).subtracting(Set(alreadyExistsIds)))
            
            return unsynchronizedIds
        }
    }
    
    func records(returnJson: Bool = false) -> AnyPublisher<[DBRecord], Error> {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return Just<[DBRecord]>([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation.tracking { db in
            // exclude json
            var sql = "SELECT id, sp2PrincipalId, battleNumber, isDetail, victory, weaponId, weaponImage, rule, gameMode, gameModeKey, stageName, killTotalCount, killCount, assistCount, specialCount, gamePaintPoint, deathCount, myPoint, otherPoint, syncDetailTime, startDateTime, udemaeName, udemaeSPlusNumber, type, leaguePoint, estimateGachiPower, playerTypeSpecies, isX, xPower FROM record WHERE sp2PrincipalId = ? ORDER BY cast(battleNumber as integer) DESC"
            
            if returnJson {
                sql = sql.replacingOccurrences(of: "battleNumber", with: "battleNumber, json")
            }
            
            return try Row
                .fetchAll(db, sql: sql, arguments: [sp2PrincipalId])
                .map { row in
                    DBRecord(row: row)
                }
        }
        .publisher(in: dbQueue, scheduling: .immediate)
        .eraseToAnyPublisher()
    }
    
    func records(start battleNumber: String? = nil, count: Int) -> [DBRecord] {
        return try! dbQueue.read { db in
            if let battleNumber = battleNumber {
                return try! DBRecord
                    .filter(DBRecord.Columns.battleNumber < battleNumber)
                    .order(DBRecord.Columns.battleNumber.desc)
                    .limit(count)
                    .fetchAll(db)
            } else {
                return try! DBRecord
                    .order(DBRecord.Columns.battleNumber.desc)
                    .limit(count)
                    .fetchAll(db)
            }
        }
    }
    
    func record(with id: Int64) -> DBRecord? {
        return try! dbQueue.read { db in
            return try? DBRecord
                .filter(DBRecord.Columns.id == id)
                .fetchOne(db)
        }
    }
    
    func totalCount() -> AnyPublisher<Int, Error> {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return Just<Int>(0)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(
                DBRecord
                    .filter(DBRecord.Columns.sp2PrincipalId == sp2PrincipalId)
                    .fetchCount
            )
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func totalKillCount() -> Int {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return 0
        }
        
        return try! dbQueue.read { db in
            let request = DBRecord.filter(
                DBRecord.Columns.sp2PrincipalId == sp2PrincipalId
            )
            .select(sum(DBRecord.Columns.killCount))
            return try! Int.fetchOne(db, request) ?? 0
        }
    }
    
    func vdWithLast500() -> [Bool] {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return []
        }
        
        return try! dbQueue.read { db in
            return try! Bool.fetchAll(
                db,
                sql: "SELECT victory FROM record WHERE sp2PrincipalId = ? ORDER BY startDateTime DESC LIMIT 0, 500",
                arguments: [sp2PrincipalId]
            )
        }
    }
    
    func totalKD() -> Int {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return 0
        }
        
        return try! dbQueue.read { db in
            let request = DBRecord.filter(
                DBRecord.Columns.sp2PrincipalId == sp2PrincipalId
            )
            .select(sum(DBRecord.Columns.killCount))
            return try! Int.fetchOne(db, request) ?? 0
        }
    }
    
    func currentSyncTotalCount(lastSyncTime: Date) -> AnyPublisher<Int, Error> {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return Just<Int>(0)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(
                DBRecord.filter(
                (DBRecord.Columns.syncDetailTime == nil || (DBRecord.Columns.syncDetailTime != nil &&
                                                            DBRecord.Columns.syncDetailTime > lastSyncTime)) &&
                    DBRecord.Columns.sp2PrincipalId == sp2PrincipalId
            ).fetchCount)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func currentSynchronizedCount(lastSyncTime: Date) -> AnyPublisher<Int, Error> {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return Just<Int>(0)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation
            .tracking(DBRecord.filter(
                DBRecord.Columns.syncDetailTime > lastSyncTime &&
                    DBRecord.Columns.sp2PrincipalId == sp2PrincipalId
            ).fetchCount)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
    
    func victoryAndDefeatCount(startTime: Date, endTime: Date = Date()) -> (Int, Int) {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return (0, 0)
        }
        
        return try! dbQueue.read { db in
            guard let victoryCount = try? Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM record WHERE victory AND startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, sp2PrincipalId]
            ),
            let defeatCount = try? Int.fetchOne(
                db,
                sql: "SELECT COUNT(*) FROM record WHERE NOT victory AND startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, sp2PrincipalId]
            ) else {
                return (0, 0)
            }
            
            return (victoryCount, defeatCount)
        }
    }
    
    func killAssistAndDeathCount(startTime: Date, endTime: Date = Date()) -> (Int, Int, Int) {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return (0, 0, 0)
        }
        
        return try! dbQueue.read { db in
            guard let killCount = try? Int.fetchOne(
                db,
                sql: "SELECT SUM(killCount) FROM record WHERE startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, sp2PrincipalId]
            ),
            let assistCount = try? Int.fetchOne(
                db,
                sql: "SELECT SUM(assistCount) FROM record WHERE startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, sp2PrincipalId]
            ),
            let deathCount = try? Int.fetchOne(
                db,
                sql: "SELECT SUM(deathCount) FROM record WHERE startDateTime > ? AND startDateTime < ? AND sp2PrincipalId = ?",
                arguments: [startTime, endTime, sp2PrincipalId]
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
            victory: victory,
            weaponId: weaponId,
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
            startDateTime: startDateTime,
            udemaeName: udemaeName,
            udemaeSPlusNumber: udemaeSPlusNumber,
            type: type,
            leaguePoint: leaguePoint,
            estimateGachiPower: estimateGachiPower,
            playerTypeSpecies: playerTypeSpecies,
            isX: isX,
            xPower: xPower
        )
        return copy
    }
}

extension DBRecord {
    var weaponImageURL: URL {
        Splatoon2API.host.appendingPathComponent(weaponImage)
    }
    
    var battle: Battle? {
        json?.decode(Battle.self)
    }
}
