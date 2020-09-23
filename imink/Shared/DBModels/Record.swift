//
//  Record.swift
//  imink
//
//  Created by Jone Wang on 2020/9/14.
//

import Foundation
import GRDB
import Combine

struct Record: Identifiable {
    
    // MARK: Column
    
    var id: Int64?
    var sp2PrincipalId: String?
    var battleNumber: String
    var json: String
    
    // If the json from /results/<id> then isDetail is ture.
    var isDetail: Bool
    
    // List item information
    var victory: Bool
    var weaponImage: String
    var rule: String
    var gameMode: String
    var stageName: String
    var killTotalCount: Int
    var deathCount: Int
    var myPoint: Double
    var otherPoint: Double
}

extension Record: Codable, FetchableRecord, MutablePersistableRecord {
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
        static let stageName = Column(CodingKeys.stageName)
        static let killTotalCount = Column(CodingKeys.killTotalCount)
        static let deathCount = Column(CodingKeys.deathCount)
        static let myPoint = Column(CodingKeys.myPoint)
        static let otherPoint = Column(CodingKeys.otherPoint)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension DerivableRequest where RowDecoder == Record { }

extension Record: Equatable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        lhs.id == rhs.id &&
            lhs.json == rhs.json &&
            lhs.isDetail == rhs.isDetail
    }
}

extension AppDatabase {
    
    // MARK: Writes
    
    /// Save a full battle record, from /results/<id>
    func saveFullBattle(_ battleObject: Dictionary<String, AnyObject>) throws {
        dbQueue.asyncWrite { db in
            guard let currentUser = AppUserDefaults.shared.user else {
                return
            }
            
            let battleNumber = battleObject["battle_number"] as! String
            
            guard let data = try? JSONSerialization.data(
                withJSONObject: battleObject,
                options: .sortedKeys
            ) else {
                return
            }
            
            guard let battleJson = String(data: data, encoding: .utf8) else {
                return
            }
            
            if var record = try Record.filter(
                Record.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                    Record.Columns.battleNumber == battleNumber
            ).fetchOne(db) {
                record.json = battleJson
                record.isDetail = true
                try record.update(db)
            }
        } completion: { _, error in
            if case let .failure(error) = error {
                print("[Database] saveFullBattle \(error)")
            }
        }
    }
    
    /// Save data from /results
    func saveSampleBattles(_ jsonResults: [String?], battles: [SP2Battle?], completed: @escaping (_ haveNewRecord: Bool) -> Void) throws {
        guard let currentUser = AppUserDefaults.shared.user else {
            return
        }
        
        var records = [Record]()
        for index in jsonResults.indices {
            guard let jsonResult = jsonResults[index] else { continue }
            guard let battle = battles[index] else { continue }
            
            records.append(
                Record(
                    sp2PrincipalId: currentUser.sp2PrincipalId,
                    battleNumber: battle.battleNumber,
                    json: jsonResult,
                    isDetail: false,
                    victory: battle.myTeamResult.key == .victory,
                    weaponImage: battle.playerResult.player.weapon.image,
                    rule: battle.rule.name,
                    gameMode: battle.gameMode.name,
                    stageName: battle.stage.name,
                    killTotalCount: battle.playerResult.killCount + battle.playerResult.assistCount,
                    deathCount: battle.playerResult.deathCount,
                    myPoint: battle.myPoint,
                    otherPoint: battle.otherPoint)
            )
        }
        
        dbQueue.asyncWrite { db in
            let battleNumbers = records.map { $0.battleNumber }
            
            let existRecords = try Record.filter(
                Record.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                    battleNumbers.contains(Record.Columns.battleNumber)
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
                print("[Database] saveSampleBattles \(error)")
            }
        }
    }
    
    // MARK: Reads
    
    func records() -> AnyPublisher<[Record], Error> {
        ValueObservation
            .tracking(Record.order(Record.Columns.battleNumber.desc).fetchAll)
            .publisher(in: dbQueue, scheduling: .immediate)
            .eraseToAnyPublisher()
    }
}

extension Record {
    func copy(with zone: NSZone? = nil) -> Record {
        let copy = Record(
            id: id,
            sp2PrincipalId: sp2PrincipalId,
            battleNumber: battleNumber,
            json: json,
            isDetail: isDetail,
            victory: victory,
            weaponImage: weaponImage,
            rule: rule,
            gameMode: gameMode,
            stageName: stageName,
            killTotalCount: killTotalCount,
            deathCount: deathCount,
            myPoint: myPoint,
            otherPoint: otherPoint
        )
        return copy
    }
}

extension Record {
    var weaponImageURL: URL {
        Splatoon2API.host.appendingPathComponent(weaponImage)
    }
    
    var battle: SP2Battle? {
        json.decode(SP2Battle.self)
    }
}
