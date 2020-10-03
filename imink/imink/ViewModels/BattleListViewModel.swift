//
//  BattleListViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import Foundation
import Combine
import os

class BattleListViewModel: ObservableObject {
    
    @Published var records: [Record] = []
    @Published var databaseRecords: [Record] = []
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var requestDetailCancellable: AnyCancellable!
    
    init() {
        // Database records publisher
        AppDatabase.shared.records()
            .catch { error -> Just<[Record]> in
                os_log("Database Error: [records] \(error.localizedDescription)")
                return Just<[Record]>([])
            }
            .assign(to: &$databaseRecords)
        
        // Handle data source of list
        $databaseRecords
            .map { records in
                if let firstRecord = records.first {
                    var firstRecord = firstRecord.copy()
                    firstRecord.id = nil
                    return [firstRecord] + records
                } else {
                    return [
                        Record(
                            battleNumber: "",
                            json: "",
                            isDetail: false,
                            victory: false,
                            weaponImage: "",
                            rule: "",
                            gameMode: "",
                            gameModeKey: "",
                            stageName: "",
                            killTotalCount: 0,
                            killCount: 0,
                            assistCount: 0,
                            specialCount: 0,
                            gamePaintPoint: 0,
                            deathCount: 0,
                            myPoint: 0,
                            otherPoint: 0
                        )
                    ]
                }
            }
            .filter { _ in AppUserDefaults.shared.user != nil }
            .assign(to: &$records)
    }
    
}
