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
    @Published var customDateClosedRange = Date()...Date()

    @Published var dates: [DateFilterItem] = FilterDate.filterKeys
        .map { DateFilterItem(id: $0, canSelect: true) }
    @Published var battleTypes: [BattleTypeFilterItem] = Battle.BattleType.filterKeys
        .map { BattleTypeFilterItem(id: $0, canSelect: true) }
    @Published var rules: [RuleFilterItem] = GameRule.Key.filterKeys
        .map { RuleFilterItem(id: $0, canSelect: true) }
    @Published var stages: [ObjectIdFilterItem] = GameData.stageIds
        .map { ObjectIdFilterItem(id: $0, canSelect: true) }
    @Published var weapons: [ObjectIdFilterItem] = GameData.weaponIds
        .map { ObjectIdFilterItem(id: $0, canSelect: true) }
        .sorted { Int($0.canSelect) > Int($1.canSelect) }
    
    private var cancelBag = Set<AnyCancellable>()

    init(_ filterContent: BattleListFilterContent) {
        currentFilterContent = filterContent
        
        if currentFilterContent.startDate != .custom {
            AppDatabase.shared.firstAndLastRecordDate {  [weak self] (firstDate, lastDate) in
                guard let `self` = self else { return }
                
                let startDate = firstDate ?? Date()
                let endDate = lastDate ?? Date()
                
                self.currentFilterContent.customDate = endDate
                self.customDateClosedRange = startDate...endDate
            }
        }
        
        $currentFilterContent
            .sink { [weak self] filterContent in
                guard let `self` = self else { return }
                
                var filterContent = filterContent
                
                AppDatabase.shared.dbPool.asyncRead { result in
                    if case .success(let db) = result {
                        let (firstDate, lastDate) = AppDatabase.shared.firstAndLastRecordDate(
                            db: db,
                            battleType: filterContent.battleType,
                            rule: filterContent.rule,
                            stageId: filterContent.stageId,
                            weaponId: filterContent.weaponId
                        )
                        
                        let startDate = firstDate ?? Date()
                        let endDate = lastDate ?? Date()
                        
                        let dates: [DateFilterItem] = FilterDate.filterKeys.map { filterDate in
                            var date = filterDate.dateValue
                            if filterDate == .custom {
                                date = filterContent.customDate
                            }
                            let filterable = AppDatabase.shared
                                .filterable(
                                    db: db,
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
                                db: db,
                                startDate: filterContent.startDateValue,
                                rule: filterContent.rule,
                                stageId: filterContent.stageId,
                                weaponId: filterContent.weaponId
                            )
                        
                        let filterableRules = AppDatabase.shared
                            .filterableRules(
                                db: db,
                                startDate: filterContent.startDateValue,
                                battleType: filterContent.battleType,
                                stageId: filterContent.stageId,
                                weaponId: filterContent.weaponId
                            )
                        
                        let filterableStageIds = AppDatabase.shared
                            .filterableStageIds(
                                db: db,
                                startDate: filterContent.startDateValue,
                                battleType: filterContent.battleType,
                                rule: filterContent.rule,
                                weaponId: filterContent.weaponId
                            )
                        
                        let filterableWeaponIds = AppDatabase.shared
                            .filterableWeaponIds(
                                db: db,
                                startDate: filterContent.startDateValue,
                                battleType: filterContent.battleType,
                                rule: filterContent.rule,
                                stageId: filterContent.stageId
                            )
                        
                        DispatchQueue.main.async {
                            self.customDateClosedRange = startDate...endDate
                            self.dates = dates
                            self.battleTypes = Battle.BattleType.filterKeys.map { BattleTypeFilterItem(id: $0, canSelect: filterableBattleTypes.contains($0)) }
                            self.rules = GameRule.Key.filterKeys.map { RuleFilterItem(id: $0, canSelect: filterableRules.contains($0)) }
                            self.stages = GameData.stageIds
                                .map { ObjectIdFilterItem(id: $0, canSelect: filterableStageIds.contains($0)) }
                            self.weapons = GameData.weaponIds
                                .map { ObjectIdFilterItem(id: $0, canSelect: filterableWeaponIds.contains($0)) }
                                .sorted { Int($0.canSelect) > Int($1.canSelect) }
                        }
                    }
                }
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
