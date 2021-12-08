//
//  BattleListFilterViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/12/8.
//

import Foundation
import Combine

class BattleListFilterViewModel: ObservableObject {
    
    @Published var stages: [FilterItem] = []
    @Published var weapons: [FilterItem] = []
    
    init() {
        let usedWeaponIds = AppDatabase.shared.usedWeaponIds()
        weapons = GameData.weaponIds
            .map { FilterItem(id: $0, canSelect: usedWeaponIds.contains($0)) }
            .sorted { ($0.canSelect ? 1 : 0) > ($1.canSelect ? 1 : 0) }
        
        stages = GameData.stageIds.map { FilterItem(id: $0, canSelect: true) }
    }
}

extension BattleListFilterViewModel {
    struct FilterItem {
        let id: String
        let canSelect: Bool
    }
}
