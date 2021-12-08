//
//  BattleListViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import Foundation
import Combine
import os

struct BattleListRowModel: Identifiable {
    
    let type: RowType
    var record: DBRecord?
    
    enum RowType: String {
        case realtime, record
    }
    
    var id: String {
        "\(type == .record ? "\(record?.battleNumber ?? "")" : "")\(type.rawValue)"
    }
    
    static let realtimeId = "realtime"
}

extension BattleListRowModel: Hashable {
    public static func == (lhs: BattleListRowModel, rhs: BattleListRowModel) -> Bool {
        lhs.record?.id == rhs.record?.id && lhs.type == rhs.type
    }
}

class BattleListViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    @Published var rows: [BattleListRowModel] = []
    @Published var databaseRecords: [DBRecord] = []
    @Published var selectedId: String?
    @Published var realtimeRow: BattleListRowModel?
    
    // Filter
    @Published var filterType: Battle.BattleType? = nil
    @Published var filterRule: GameRule.Key? = nil
    @Published var filterStageId: String? = nil
    @Published var filterWeaponId: String? = nil
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var requestDetailCancellable: AnyCancellable!
    
    init() {
        let isLogined = AppUserDefaults.shared.sessionToken != nil
        updateLoginStatus(isLogined: isLogined)
    }
    
    func updateLoginStatus(isLogined: Bool) {
        cancelBag = Set<AnyCancellable>()
        
        self.isLogined = isLogined
        
        if !isLogined {
            databaseRecords = []
            rows = []
            selectedId = nil
            return
        }
        
        // Database records publisher
        AppDatabase.shared.records()
            .catch { error -> Just<[DBRecord]> in
                os_log("Database Error: [records] \(error.localizedDescription)")
                return Just<[DBRecord]>([])
            }
            .assign(to: \.databaseRecords, on: self)
            .store(in: &cancelBag)
        
        // Handle data source of list
        $databaseRecords
            .combineLatest($filterType.removeDuplicates())
            .map { (records, type) -> [DBRecord] in
                if let type = type {
                    return records.filter { GameMode.Key(rawValue: $0.gameModeKey)?.battleType == type }
                }
                
                return records
            }
            .combineLatest($filterRule.removeDuplicates())
            .map { (records, rule) -> [DBRecord] in
                if let rule = rule {
                    return records.filter { GameRule.Key(rawValue: $0.ruleKey) == rule }
                }
                
                return records
            }
//            .combineLatest($filterStageId.removeDuplicates())
//            .map { (records, stageId) -> [DBRecord] in
//                if let stageId = stageId {
//                    return records.filter { $0.stageId == "\(stageId)" }
//                }
//
//                return records
//            }
            .combineLatest($filterWeaponId.removeDuplicates())
            .map { (records, weaponId) -> [DBRecord] in
                if let weaponId = weaponId {
                    return records.filter { $0.weaponId == "\(weaponId)" }
                }
                
                return records
            }
            .map { $0.map { BattleListRowModel(type: .record, record: $0) } }
            .map { rows in
                let realtimeRow = BattleListRowModel(
                    type: .realtime,
                    record: rows.first?.record
                )
                
                if self.selectedId == BattleListRowModel.realtimeId {
                    self.realtimeRow = realtimeRow
                } else {
                    self.realtimeRow = nil
                }
                
                if rows.first != nil {
                    return [realtimeRow] + rows
                } else {
                    return [realtimeRow]
                }
            }
            .assign(to: \.rows, on: self)
            .store(in: &cancelBag)
    }
}

fileprivate extension GameRule.Key {
    static func with(index: Int) -> Self? {
        switch (index) {
        case 0:
            return nil
        case 1:
            return .turfWar
        case 2:
            return .splatZones
        case 3:
            return .towerControl
        case 4:
            return .rainmaker
        case 5:
            return .clamBlitz
        default:
            return nil
        }
    }
}
