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
    var ruleKey: String
    var gameMode: String
    var gameModeKey: String
    var stageName: String
    var stageId: String
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
        static let ruleKey = Column(CodingKeys.rule)
        static let gameMode = Column(CodingKeys.gameMode)
        static let gameModeKey = Column(CodingKeys.gameModeKey)
        static let stageName = Column(CodingKeys.stageName)
        static let stageId = Column(CodingKeys.stageId)
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

extension DBRecord {
    static func load(data: Data) -> DBRecord? {
        guard let json = String(data: data, encoding: .utf8),
              let battle = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let playerResult = battle["player_result"] as? [String: Any],
              let player = playerResult["player"] as? [String: Any],
              let weapon = player["weapon"] as? [String: Any],
              let rule = battle["rule"] as? [String: Any],
              let gameMode = battle["game_mode"] as? [String: Any],
              let stage = battle["stage"] as? [String: Any],
              let playerType = player["player_type"] as? [String: Any],
              let myTeamResult = battle["my_team_result"] as? [String: Any],
              
              let sp2PrincipalId = player["principal_id"] as? String,
              let battleNumber = battle["battle_number"] as? String,
              let resultKey = myTeamResult["key"] as? String,
              let weaponId = weapon["id"] as? String,
              let weaponImage = weapon["image"] as? String,
              let ruleName = rule["name"] as? String,
              let ruleKey = rule["key"] as? String,
              let gameModeName = gameMode["name"] as? String,
              let gameModeKey = gameMode["key"] as? String,
              let stageName = stage["name"] as? String,
              let stageId = stage["id"] as? String,
              let killCount = playerResult["kill_count"] as? Int,
              let assistCount = playerResult["assist_count"] as? Int,
              let specialCount = playerResult["special_count"] as? Int,
              let gamePaintPoint = playerResult["game_paint_point"] as? Int,
              let deathCount = playerResult["death_count"] as? Int,
              let startTimestamp = battle["start_time"] as? Double,
              let battleType = Battle.BattleType(rawValue: battle["type"] as? String ?? ""),
              let species = Player.PlayerType.Species(rawValue: playerType["species"] as? String ?? "")
        else {
            return nil
        }
        
        let udemae = battle["udemae"] as? [String: Any]
        let udemaeName = udemae?["name"] as? String
            
        var myPoint: Double
        var otherPoint: Double
        if ruleKey == GameRule.Key.turfWar.rawValue {
            myPoint = battle["my_team_percentage"] as! Double
            otherPoint = battle["other_team_percentage"] as! Double
        } else {
            myPoint = battle["my_team_count"] as! Double
            otherPoint = battle["other_team_count"] as! Double
        }
        
        let sPlusNumber = udemae?["s_plus_number"] as? Int
        let leaguePoint = battle["league_point"] as? Double
        let estimateGachiPower = battle["estimate_gachi_power"] as? Int
        let isX = udemae?["is_x"] as? Bool
        let xPower = battle["x_power"] as? Double
        
        return DBRecord(
            sp2PrincipalId: sp2PrincipalId,
            battleNumber: battleNumber,
            json: json,
            victory: resultKey == TeamResult.Key.victory.rawValue,
            weaponId: weaponId,
            weaponImage: Splatoon2API.host.appendingPathComponent(weaponImage).absoluteString,
            rule: ruleName,
            ruleKey: ruleKey,
            gameMode: gameModeName,
            gameModeKey: gameModeKey,
            stageName: stageName,
            stageId: stageId,
            killTotalCount: killCount + assistCount,
            killCount: killCount,
            assistCount: assistCount,
            specialCount: specialCount,
            gamePaintPoint: gamePaintPoint,
            deathCount: deathCount,
            myPoint: myPoint,
            otherPoint: otherPoint,
            startDateTime: Date(timeIntervalSince1970: startTimestamp),
            udemaeName: udemaeName,
            udemaeSPlusNumber: sPlusNumber,
            type: battleType,
            leaguePoint: leaguePoint,
            estimateGachiPower: estimateGachiPower,
            playerTypeSpecies: species,
            isX: isX ?? false,
            xPower: xPower)
    }
}

extension AppDatabase {
    
    // MARK: Writes
    
    func saveBattle(data: Data) {
        dbQueue.asyncWrite { db in
            if let record = DBRecord.load(data: data) {
                _ = try self.saveBattle(db: db, record: record)
            }
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveBattle] \(error.localizedDescription)")
            }
        }
    }
    
    func saveBattles(records: [DBRecord], progress: @escaping ((Double, Int, Error?) -> Void)) {
        dbQueue.asyncWrite { db in
            var saveCount = 0
            for (i, record) in records.enumerated() {
                if try self.saveBattle(db: db, record: record) {
                    saveCount += 1
                }
                progress(Double(i + 1) / Double(records.count), saveCount, nil)
            }
        } completion: { _, result in
            if case let .failure(error) = result {
                progress(1, 0, error)
                os_log("Database Error: [saveBattle] \(error.localizedDescription)")
            }
        }
    }
    
    private func saveBattle(db: Database, record: DBRecord) throws -> Bool {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId,
              record.sp2PrincipalId == sp2PrincipalId else {
            return false
        }
        
        if try DBRecord.filter(
            DBRecord.Columns.sp2PrincipalId == sp2PrincipalId &&
                DBRecord.Columns.battleNumber == record.battleNumber
        ).fetchCount(db) > 0 {
            return false
        }
        
        var record = record
        try record.insert(db)
        
        return true
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
            var sql = "SELECT id, sp2PrincipalId, battleNumber, isDetail, victory, weaponId, weaponImage, rule, ruleKey, gameMode, gameModeKey, stageName, stageId, killTotalCount, killCount, assistCount, specialCount, gamePaintPoint, deathCount, myPoint, otherPoint, syncDetailTime, startDateTime, udemaeName, udemaeSPlusNumber, type, leaguePoint, estimateGachiPower, playerTypeSpecies, isX, xPower FROM record WHERE sp2PrincipalId = ? ORDER BY startDateTime DESC"
            
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
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return []
        }
        
        return try! dbQueue.read { db in
            if let battleNumber = battleNumber {
                return try! DBRecord
                    .filter(
                        DBRecord.Columns.battleNumber < battleNumber &&
                            DBRecord.Columns.sp2PrincipalId == sp2PrincipalId
                    )
                    .order(DBRecord.Columns.battleNumber.desc)
                    .limit(count)
                    .fetchAll(db)
            } else {
                return try! DBRecord
                    .filter(DBRecord.Columns.sp2PrincipalId == sp2PrincipalId)
                    .order(DBRecord.Columns.battleNumber.desc)
                    .limit(count)
                    .fetchAll(db)
            }
        }
    }
    
    func record(with id: Int64) -> DBRecord? {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return nil
        }
        
        return try! dbQueue.read { db in
            return try? DBRecord
                .filter(
                    DBRecord.Columns.id == id &&
                        DBRecord.Columns.sp2PrincipalId == sp2PrincipalId)
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
    
    func filterable(
        startDate: Date,
        battleType: Battle.BattleType?,
        rule: GameRule.Key?,
        stageId: String?,
        weaponId: String?
    ) -> Bool {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return false
        }
        
        var args: [DatabaseValueConvertible] = [sp2PrincipalId, startDate]
        var sql = "SELECT COUNT(*) FROM record WHERE sp2PrincipalId = ? AND startDateTime > ? "
        
        if let battleType = battleType {
            switch battleType {
            case .regular, .gachi, .private:
                sql += "AND gameModeKey = ? "
                args.append(battleType.rawValue)
            case .league:
                sql += "AND (gameModeKey = ? OR gameModeKey = ?) "
                args.append(GameMode.Key.leaguePair.rawValue)
                args.append(GameMode.Key.leagueTeam.rawValue)
            case .fes:
                sql += "AND (gameModeKey = ? OR gameModeKey = ?) "
                args.append(GameMode.Key.fesSolo.rawValue)
                args.append(GameMode.Key.fesTeam.rawValue)
            }
        }
        
        if let rule = rule {
            sql += "AND ruleKey = ? "
            args.append(rule.rawValue)
        }
        
        if let stageId = stageId {
            sql += "AND stageId = ? "
            args.append(stageId)
        }
        
        if let weaponId = weaponId {
            sql += "AND weaponId = ? "
            args.append(weaponId)
        }
        
        return try! dbQueue.read { db in
            guard let count = try? Int.fetchOne(
                db,
                sql: sql,
                arguments: StatementArguments(args)
            ) else {
                return false
            }
            
            return count > 0
        }
    }
    
    func filterableBattleTypes(
        startDate: Date?,
        rule: GameRule.Key?,
        stageId: String?,
        weaponId: String?
    ) -> [Battle.BattleType] {
        filterableIds(
            select: "gameModeKey",
            startDate: startDate,
            battleType: nil,
            rule: rule,
            stageId: stageId,
            weaponId: weaponId
        ).map { GameMode.Key(rawValue: $0)!.battleType }
    }
    
    func filterableRules(
        startDate: Date?,
        battleType: Battle.BattleType?,
        stageId: String?,
        weaponId: String?
    ) -> [GameRule.Key] {
        filterableIds(
            select: "ruleKey",
            startDate: startDate,
            battleType: battleType,
            rule: nil,
            stageId: stageId,
            weaponId: weaponId
        ).map { GameRule.Key(rawValue: $0)! }
    }
    
    func filterableWeaponIds(
        startDate: Date?,
        battleType: Battle.BattleType?,
        rule: GameRule.Key?,
        stageId: String?
    ) -> [String] {
        filterableIds(
            select: "weaponId",
            startDate: startDate,
            battleType: battleType,
            rule: rule,
            stageId: stageId,
            weaponId: nil
        )
    }
    
    func filterableStageIds(
        startDate: Date?,
        battleType: Battle.BattleType?,
        rule: GameRule.Key?,
        weaponId: String?
    ) -> [String] {
        filterableIds(
            select: "stageId",
            startDate: startDate,
            battleType: battleType,
            rule: rule,
            stageId: nil,
            weaponId: weaponId
        )
    }
    
    private func filterableIds(
        select: String,
        startDate: Date?,
        battleType: Battle.BattleType?,
        rule: GameRule.Key?,
        stageId: String?,
        weaponId: String?
    ) -> [String] {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return []
        }
        
        var args: [DatabaseValueConvertible] = [sp2PrincipalId]
        var sql = "SELECT \(select) FROM record WHERE sp2PrincipalId = ? "
        
        if let startDate = startDate {
            sql += "AND startDateTime > ? "
            args.append(startDate)
        }
        
        if let battleType = battleType {
            switch battleType {
            case .regular, .gachi, .private:
                sql += "AND gameModeKey = ? "
                args.append(battleType.rawValue)
            case .league:
                sql += "AND (gameModeKey = ? OR gameModeKey = ?) "
                args.append(GameMode.Key.leaguePair.rawValue)
                args.append(GameMode.Key.leagueTeam.rawValue)
            case .fes:
                sql += "AND (gameModeKey = ? OR gameModeKey = ?) "
                args.append(GameMode.Key.fesSolo.rawValue)
                args.append(GameMode.Key.fesTeam.rawValue)
            }
        }
        
        if let rule = rule {
            sql += "AND ruleKey = ? "
            args.append(rule.rawValue)
        }
        
        if let stageId = stageId {
            sql += "AND stageId = ? "
            args.append(stageId)
        }
        
        if let weaponId = weaponId {
            sql += "AND weaponId = ? "
            args.append(weaponId)
        }
        
        sql += "GROUP BY \(select)"
        
        return try! dbQueue.read { db in
            guard let usedWeaponIds = try? String.fetchAll(
                db,
                sql: sql,
                arguments: StatementArguments(args)
            ) else {
                return []
            }
            
            return usedWeaponIds
        }
    }
    
    func firstAndLastRecordDate() -> (Date?, Date?) {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return (nil, nil)
        }
        
        return try! dbQueue.read { db in
            guard let dates = try? Date.fetchAll(
                db,
                sql: "SELECT MIN(startDateTime) FROM record WHERE sp2PrincipalId = ? " +
                "UNION ALL " +
                "SELECT MAX(startDateTime) FROM record WHERE sp2PrincipalId = ?",
                arguments: [sp2PrincipalId, sp2PrincipalId]
            ) else {
                return (nil, nil)
            }
            
            return (dates.first, dates.last)
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
            ruleKey: ruleKey,
            gameMode: gameMode,
            gameModeKey: gameModeKey,
            stageName: stageName,
            stageId: stageId,
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
