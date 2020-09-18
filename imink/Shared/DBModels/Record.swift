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
    
    // MARK: Property
    
    var battle: SP2Battle?
}

extension Record: Codable, FetchableRecord, MutablePersistableRecord {
    // Define database columns from CodingKeys
    fileprivate enum Columns {
        static let id = Column(CodingKeys.id)
        static let sp2PrincipalId = Column(CodingKeys.sp2PrincipalId)
        static let battleNumber = Column(CodingKeys.battleNumber)
        static let json = Column(CodingKeys.json)
        static let isDetail = Column(CodingKeys.isDetail)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
    
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id
        container["sp2PrincipalId"] = sp2PrincipalId
        container["battleNumber"] = battleNumber
        container["json"] = json
        container["isDetail"] = isDetail
    }
}

extension DerivableRequest where RowDecoder == Record { }

extension Record: Hashable {
    static func == (lhs: Record, rhs: Record) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.isDetail)
    }
}

extension AppDatabase {
    
    // MARK: Writes
    
    /// Save a full battle record, from /results/<id>
    func saveFullBattle(_ battleObject: Dictionary<String, AnyObject>) throws {
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
        
        try dbQueue.write { db in
            if var record = try Record.filter(
                Record.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                    Record.Columns.battleNumber == battleNumber
            ).fetchOne(db) {
                record.json = battleJson
                record.isDetail = true
                try record.update(db)
            }
        }
    }
    
    /// Save data from /results
    func saveSampleBattles(_ battleObjects: [Dictionary<String, AnyObject>], haveNewRecord: inout Bool) throws {
        guard let currentUser = AppUserDefaults.shared.user else {
            return
        }
        
        let battleJsons = battleObjects.map { object -> (String, String?) in
            let battleNumber = object["battle_number"] as! String
            
            guard let data = try? JSONSerialization.data(
                withJSONObject: object,
                options: .sortedKeys
            ) else {
                return (battleNumber, nil)
            }
            
            return (battleNumber, String(data: data, encoding: .utf8))
        }
        
        let records = battleJsons.map {
            $0.1 != nil ?
                Record(sp2PrincipalId: currentUser.sp2PrincipalId,
                       battleNumber: $0.0,
                       json: $0.1!,
                       isDetail: false):
                nil
        }
        
        try dbQueue.write { db in
            for record in records.reversed() {
                if var record = record, try Record.filter(
                    Record.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                        Record.Columns.battleNumber == record.battleNumber
                ).fetchOne(db) == nil {
                    haveNewRecord = true
                    try record.insert(db)
                }
            }
        }
    }
    
    // MARK: Reads
    
    func records() -> AnyPublisher<[Record], Error> {
        ValueObservation
            .tracking(Record.order(Record.Columns.id.desc).fetchAll)
            .map {
                $0.map {
                    var record = $0
                    record.battle = $0.json.decode(SP2Battle.self)
                    return record
                }
            }
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
            battle: battle
        )
        return copy
    }
}
