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
    var id: String {
        "\(record?.battleNumber ?? "")\(type.rawValue)\(isSelected)"
    }
    
    let type: RowType
    var record: DBRecord?
    var isSelected = false
    
    enum RowType: String {
        case realtime, record
    }
}

extension BattleListRowModel: Hashable {
    public static func == (lhs: BattleListRowModel, rhs: BattleListRowModel) -> Bool {
        lhs.record?.id == rhs.record?.id && lhs.type == rhs.type
    }
}

class BattleListViewModel: ObservableObject {
    
    @Published var rows: [BattleListRowModel] = []
    @Published var databaseRecords: [DBRecord] = []
    @Published var selectedReocrdId: Int64? = nil
    @Published var isLoadingRealTimeData = false
    
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
            .map { records -> [BattleListRowModel] in
                let selectedRecord = self.rows.first { $0.isSelected && $0.type == .record }?.record
                return records.map { record in
                    if let selectedRecord = selectedRecord,
                       selectedRecord.battleNumber == record.battleNumber {
                        return BattleListRowModel(type: .record, record: record, isSelected: true)
                    } else {
                        return BattleListRowModel(type: .record, record: record)
                    }
                }
            }
            .map { rows in
                if var firstRow = rows.first {
                    firstRow.record?.id = -1
                    return [
                        BattleListRowModel(
                                type: .realtime,
                                record: firstRow.record,
                                isSelected: self.rows.first?.isSelected ?? false
                        )
                    ] + rows
                } else {
                    return [BattleListRowModel(type: .realtime, record: nil)]
                }
            }
            .filter { _ in AppUserDefaults.shared.user != nil }
            .assign(to: &$rows)
        
        $selectedReocrdId
            .map { selectedId in
                var rows: [BattleListRowModel] = []
                for row in self.rows {
                    rows.append(
                        BattleListRowModel(
                            type: row.type,
                            record: row.record,
                            isSelected: row.record?.id == selectedId
                        )
                    )
                }
                return rows
            }
            .assign(to: &$rows)
        
        NotificationCenter.default
            .publisher(for: .isLoadingRealTimeBattleResult)
            .map { $0.object as! Bool }
            .assign(to: &$isLoadingRealTimeData)
    }
}
