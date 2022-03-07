//
//  BattleDetailViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/2/8.
//

import Combine
import Foundation
import os

class BattleDetailContainerViewModel: ObservableObject {
    @Published var pages: [BattleDetailViewModel] = []
    @Published var currentPageIndex: Int = 0
    @Published var currentBattleNumber: String? = nil
    @Published var isRealtime: Bool = false
    @Published var currentPageId: Int64? = nil

    private var cancelBag = Set<AnyCancellable>()

    @Published var record: DBRecord?
    @Published var filterIndex: Int = 0

    func update(record: DBRecord?, initPageId: Int64, filterIndex: Int) {
        self.filterIndex = filterIndex
        currentPageId = initPageId
        currentBattleNumber = record?.battleNumber

        // Load the first data to be displayed.
        Just<Int>.init(0)
            .combineLatest($pages)
            .sink { _, pages in
                let index = pages.firstIndex { $0.id == initPageId } ?? 0

                // Pre-decode the Battle model adjacent to the current index.
                for i in (index - 1) ... (index + 1) {
                    // Data is loaded before entering the page.
                    // So here I use synchronous loading.
                    if pages.indices.contains(i) {
                        pages[i].loadBattle(sync: true)
                    }
                }
                self.currentPageIndex = index
            }
            .store(in: &cancelBag)
    }

    init(records: AnyPublisher<[DBRecord], Never>, record: DBRecord?, initPageId: Int64, filterIndex: Int) {
        update(record: record, initPageId: initPageId, filterIndex: filterIndex)

        // Database records publisher
//        let recordUpdatePublisher = AppDatabase.shared.records()
//            .catch { error -> Just<[DBRecord]> in
//                os_log("Database Error: [records] \(error.localizedDescription)")
//                return Just<[DBRecord]>([])
//            }
//            .eraseToAnyPublisher()
//            .share()

        records
            .combineLatest($filterIndex)
            .map { (records, filterIndex) -> [DBRecord] in
                if let filterRule = GameRule.Key.with(index: filterIndex) {
                    return records.filter { GameRule.Key(rawValue: $0.ruleKey) == filterRule }
                } else {
                    return records
                }
            }
            .map { records -> [BattleDetailViewModel] in
                if let firstRecord = records.first {
                    return [BattleDetailViewModel(record: firstRecord, isRealtime: true)] +
                        records.map { record in BattleDetailViewModel(record: record, isRealtime: false) }
                }
                return []
            }
            .assign(to: \.pages, on: self)
            .store(in: &cancelBag)

        let currentPageIndexPulisher = $currentPageId
            .removeDuplicates()
            .combineLatest($pages)
            .map { id, pages in
                (Int(pages.firstIndex { $0.id == id } ?? 0), pages)
            }
            .eraseToAnyPublisher()
            .share()
        
        currentPageIndexPulisher
            .map { index, _ in
                index
            }
            .print()
            .assign(to: \.currentPageIndex, on: self)
            .store(in: &cancelBag)

        currentPageIndexPulisher
            .sink { index, pages in
                // Pre-decode the Battle model adjacent to the current index.
                for i in (index - 1) ... (index + 1) {
                    if pages.indices.contains(i) {
                        pages[i].loadBattle()
                    }
                }
            }
            .store(in: &cancelBag)

        currentPageIndexPulisher
            .map { (index, pages) -> String? in
                if !pages.indices.contains(index) { return nil }
                return pages[index].record.battleNumber
            }
            .assign(to: \.currentBattleNumber, on: self)
            .store(in: &cancelBag)
    }
    
    func recordIndex(with recordId: Int64) -> Int? {
        pages.firstIndex { $0.id == recordId }
    }
}
