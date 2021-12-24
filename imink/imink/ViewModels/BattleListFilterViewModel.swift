//
//  BattleListFilterViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/12/8.
//

import Foundation
import Combine

protocol BattleListFilterItem: Hashable {
    associatedtype IdType
    
    var id: IdType { get }
    var canSelect: Bool { get }
}

class BattleListFilterViewModel: ObservableObject {
    
    @Published var currentFilterContent: BattleListFilterContent
    @Published var customDateClosedRange: ClosedRange<Date>

    @Published var dates: [DateFilterItem] = []
    @Published var battleTypes: [BattleTypeFilterItem] = []
    @Published var rules: [RuleFilterItem] = []
    @Published var stages: [ObjectIdFilterItem] = []
    @Published var weapons: [ObjectIdFilterItem] = []
    
    private var cancelBag = Set<AnyCancellable>()

    init(_ filterContent: BattleListFilterContent) {
        currentFilterContent = filterContent
        customDateClosedRange = Date()...Date()
        
        if currentFilterContent.startDate != .custom {
            let (firstDate, lastDate) = AppDatabase.shared.firstAndLastRecordDate()
            currentFilterContent.customDate = firstDate ?? Date()
            customDateClosedRange = (firstDate ?? Date())...(lastDate ?? Date())
        }
        
        $currentFilterContent
            .sink { [weak self] filterContent in
                guard let `self` = self else { return }
                
                var filterContent = filterContent
                
                self.dates = FilterDate.filterKeys.map { filterDate in
                    var date = filterDate.dateValue
                    if filterDate == .custom {
                        date = filterContent.customDate
                    }
                    let filterable = AppDatabase.shared
                        .filterable(
                            startDate: date,
                            battleType: filterContent.battleType,
                            rule: filterContent.rule,
                            stageId: filterContent.stageId,
                            weaponId: filterContent.weaponId
                        )
                    return DateFilterItem(id: filterDate, canSelect: filterable)
                }
                
                if let customDate = self.dates.last, !customDate.canSelect {
                    filterContent.startDate = nil
                }
                
                let filterableBattleTypes = AppDatabase.shared
                    .filterableBattleTypes(
                        startDate: filterContent.startDateValue,
                        rule: filterContent.rule,
                        stageId: filterContent.stageId,
                        weaponId: filterContent.weaponId
                    )
                self.battleTypes = Battle.BattleType.filterKeys.map { BattleTypeFilterItem(id: $0, canSelect: filterableBattleTypes.contains($0)) }
                
                let filterableRules = AppDatabase.shared
                    .filterableRules(
                        startDate: filterContent.startDateValue,
                        battleType: filterContent.battleType,
                        stageId: filterContent.stageId,
                        weaponId: filterContent.weaponId
                    )
                self.rules = GameRule.Key.filterKeys.map { RuleFilterItem(id: $0, canSelect: filterableRules.contains($0)) }
                
                let filterableStageIds = AppDatabase.shared
                    .filterableStageIds(
                        startDate: filterContent.startDateValue,
                        battleType: filterContent.battleType,
                        rule: filterContent.rule,
                        weaponId: filterContent.weaponId
                    )
                self.stages = GameData.stageIds
                    .map { ObjectIdFilterItem(id: $0, canSelect: filterableStageIds.contains($0)) }
                
                let filterableWeaponIds = AppDatabase.shared
                    .filterableWeaponIds(
                        startDate: filterContent.startDateValue,
                        battleType: filterContent.battleType,
                        rule: filterContent.rule,
                        stageId: filterContent.stageId
                    )
                self.weapons = GameData.weaponIds
                    .map { ObjectIdFilterItem(id: $0, canSelect: filterableWeaponIds.contains($0)) }
                    .sorted { Int($0.canSelect) > Int($1.canSelect) }
            }
            .store(in: &cancelBag)
    }
}

extension BattleListFilterViewModel {
    
    enum FilterDate: Hashable {
        case sevenDays
        case oneMonth
        case threeMonth
        case oneYear
        case custom
        
        static var filterKeys: [BattleListFilterViewModel.FilterDate] {
            [.sevenDays, .oneMonth, .threeMonth, .oneYear, .custom]
        }
        
        var dateValue: Date {
            let now = Date()
            
            var baseTime = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: now)!
            baseTime = Calendar.current.date(byAdding: .day, value: 1, to: baseTime)!
            
            switch self {
            case .sevenDays:
                return Calendar.current.date(byAdding: .weekday, value: -1, to: baseTime)!
            case .oneMonth:
                return Calendar.current.date(byAdding: .month, value: -1, to: baseTime)!
            case .threeMonth:
                return Calendar.current.date(byAdding: .month, value: -3, to: baseTime)!
            case .oneYear:
                return Calendar.current.date(byAdding: .year, value: -1, to: baseTime)!
            case .custom:
                return Date()
            }
        }
    }
    
    struct DateFilterItem: BattleListFilterItem {
        typealias IdType = FilterDate
        
        let id: FilterDate
        let canSelect: Bool
    }
    
    struct ObjectIdFilterItem: BattleListFilterItem {
        let id: String
        let canSelect: Bool
    }
    
    struct BattleTypeFilterItem: BattleListFilterItem {
        let id: Battle.BattleType
        let canSelect: Bool
    }
    
    struct RuleFilterItem: BattleListFilterItem {
        let id: GameRule.Key
        let canSelect: Bool
    }
}

fileprivate extension Battle.BattleType {
    static var filterKeys: [Battle.BattleType] {
        [.regular, .gachi, .league, .private, .fes]
    }
}

extension GameRule.Key {
    static var filterKeys: [GameRule.Key] {
        [.turfWar, .splatZones, .towerControl, .rainmaker, .clamBlitz]
    }
}

fileprivate extension BattleListFilterContent {
    var startDateValue: Date? {
        if startDate == .custom {
            return customDate
        }
        
        return startDate?.dateValue
    }
}
