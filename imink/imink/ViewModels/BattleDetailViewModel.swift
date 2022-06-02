//
//  BattleDetailViewModel.swift
//  imink
//
//  Created by Jone Wang on 2022/3/4.
//

import Foundation

class BattleDetailViewModel: ObservableObject, Identifiable {
    @Published var battle: Battle? = nil
    
    let record: DBRecord
    
    var id: Int64? {
        record.id
    }
    
    init(record: DBRecord) {
        self.record = record
    }
    
    func loadBattle(sync: Bool = false) {
        guard let id = record.id, self.battle == nil else {
            return
        }
        
        if sync {
            let dbRecord = AppDatabase.shared.record(with: id)
            self.battle = dbRecord?.battle
        } else {
            DispatchQueue(label: "", qos: .background, attributes: .concurrent).async {
                let dbRecord = AppDatabase.shared.record(with: id)
                DispatchQueue.main.async {
                    self.battle = dbRecord?.battle
                }
            }
        }
    }
}
