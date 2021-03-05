//
//  BattleDetailViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import Foundation
import Combine

class BattleDetailViewModel: ObservableObject {
    @Published var battle: Battle? = nil
    
    private var cancelBag = Set<AnyCancellable>()
    
    func load(id: Int64?) {
        guard let id = id else {
            return
        }
        
        let dbRecord = AppDatabase.shared.record(with: id)
        self.battle = dbRecord?.battle
    }
}
