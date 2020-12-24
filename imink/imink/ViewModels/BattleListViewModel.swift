//
//  BattleListViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import Foundation
import Combine
import os

struct BattleListRowModel {
    let type: RowType
    let record: DBRecord?
    
    enum RowType {
        case realtime, record
    }
}

extension BattleListRowModel: Hashable {
    
}

class BattleListViewModel: ObservableObject {
    
    @Published var rows: [BattleListRowModel] = []
    @Published var databaseRecords: [DBRecord] = []
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var requestDetailCancellable: AnyCancellable!
    
    init() {
        // Database records publisher
        AppDatabase.shared.records()
            .catch { error -> Just<[DBRecord]> in
                os_log("Database Error: [records] \(error.localizedDescription)")
                return Just<[DBRecord]>([])
            }
            .assign(to: &$databaseRecords)
        
        // Handle data source of list
        $databaseRecords
            .map { $0.map { record in BattleListRowModel(type: .record, record: record) } }
            .map { rows in
                if let firstRow = rows.first {
                    return [BattleListRowModel(type: .realtime, record: firstRow.record)] + rows
                } else {
                    return [BattleListRowModel(type: .realtime, record: nil)]
                }
            }
            .filter { _ in AppUserDefaults.shared.user != nil }
            .assign(to: &$rows)
    }
    
    
    let numberOfPage = 20
        
    func nextPage() {
        // TODO: Pagination
        return
        var battleNumber: String? = nil
        if let lastRecord = databaseRecords.last {
            battleNumber = lastRecord.battleNumber
        }
        
        let loadedRecords = AppDatabase.shared.records(start: battleNumber, count: numberOfPage)
        databaseRecords += loadedRecords
    }
    
}
