//
//  BattleListViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import Foundation
import Combine
import os
import SwiftUI

struct BattleListRowModel: Identifiable {
    
    let type: RowType
    var record: DBRecord?
    
    enum RowType: String {
        case realtime, record
    }
    
    var id: Int64 {
        if type == .record, let record = record {
            return record.id ?? 0
        } else {
            return BattleListRowModel.realtimeId
        }
//        "\(type == .record ? "\(record?.battleNumber ?? "")" : "")|\(type.rawValue)"
    }
    
    static let realtimeId: Int64 = -1
}

extension BattleListRowModel: Hashable {
    public static func == (lhs: BattleListRowModel, rhs: BattleListRowModel) -> Bool {
        lhs.record?.id == rhs.record?.id && lhs.type == rhs.type
    }
}

class BattleListViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    @Published var rows: [BattleListRowModel] = []
    @Published var selectedRowId: Int64?
    @Published var realtimeRow: BattleListRowModel?
    @Published var currentFilterIndex: Int = 0
    
    @Published var databaseRecords: [DBRecord] = []
    
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
            rows = []
            selectedRowId = nil
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
            .combineLatest($currentFilterIndex)
            .map { (records, filterIndex) -> [DBRecord] in
                if let filterRule = GameRule.Key.with(index: filterIndex) {
                    return records.filter { GameRule.Key(rawValue: $0.ruleKey) == filterRule }
                } else {
                    return records
                }
            }
            .map { $0.map { BattleListRowModel(type: .record, record: $0) } }
            .map { rows in
                let realtimeRow = BattleListRowModel(
                    type: .realtime,
                    record: rows.first?.record
                )
                
                if self.selectedRowId == BattleListRowModel.realtimeId {
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

