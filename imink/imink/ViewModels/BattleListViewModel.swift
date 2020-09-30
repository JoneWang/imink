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
    
    @Published var isLoadingDetail = false
    @Published var autoRefresh = false
    @Published var isLogin = false
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var requestDetailCancellable: AnyCancellable!
    
    init() {
        // Database records publisher
        AppDatabase.shared.records()
            .catch { error -> Just<[Record]> in
                os_log("Database Error: [records] \(error.localizedDescription)")
                return Just<[Record]>([])
            }
            .map {
                return $0
            }
            .assign(to: \.databaseRecords, on: self)
            .store(in: &self.cancelBag)
        
        // Synchronizing the record where first isDetail is false
        $databaseRecords
            .compactMap { $0.first(where: { !$0.isDetail }) }
            .flatMap { self.requestBattleDetail(battleNumber: $0.battleNumber) }
            .catch { error -> Just<Data> in
                os_log("API Error: [splatoon2/battles/id] \(error.localizedDescription)")
                return Just<Data>(Data())
            }
            .sink { [weak self] data in
                guard let `self` = self else { return }
                self.updateRecordDetail(data)
                
                if self.databaseRecords.filter({ !$0.isDetail }).count == 0 {
                    self.isLoadingDetail = false
                }
            }
            .store(in: &cancelBag)
        
        // Handle data source of list
        $databaseRecords
            .map { records in
                if let firstRecord = records.first {
                    var firstRecord = firstRecord.copy()
                    firstRecord.id = nil
                    print(self.isLogin)
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
                            stageName: "",
                            killTotalCount: 0,
                            deathCount: 0,
                            myPoint: 0,
                            otherPoint: 0
                        )
                    ]
                }
            }
            .filter { _ in AppUserDefaults.shared.user != nil }
            .assign(to: &$records)
        
        $autoRefresh
            .sink { [weak self] isAutoRefresh in
                if isAutoRefresh {
                    self?.startRealTimeDataLoop()
                }
            }
            .store(in: &cancelBag)
        
        $isLogin
            .sink { [weak self] isLogin in
                guard let `self` = self else { return }
                
                self.autoRefresh = isLogin
            }
            .store(in: &cancelBag)
        
        isLogin = AppUserDefaults.shared.user != nil
    }
    
}

// MARK: Real time

extension BattleListViewModel {
    
    func startRealTimeDataLoop() {
        NotificationCenter.default.post(
            name: .isLoadingRealTimeBattleResult,
            object: true
        )
        syncResultsToDatabase {
            NotificationCenter.default.post(
                name: .isLoadingRealTimeBattleResult,
                object: false
            )
            
            if !self.autoRefresh { return }
            
            // Next request after delayed for 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.startRealTimeDataLoop()
            }
        }
    }
    
    func syncResultsToDatabase(finished: (() -> Void)? = nil) {
        requestBattleOverview()
            .sink { completion in
                finished?()
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    if case APIError.authorizationError = error {
                        // iksm_session invalid
                        // TODO: Recapture iksm_session
                    } else {
                        // TODO: Other errors
                        os_log("API Error: [splatoon2/results] \(error.localizedDescription)")
                    }
                }
            } receiveValue: { data in
                self.saveRecordsData(data) { [weak self] _ in
                    guard let `self` = self else { return }
                    
                    if self.records.filter({ !$0.isDetail }).count > 0 && !self.isLoadingDetail {
                        // Trigger detail request
                        Just<[Record]>(self.databaseRecords)
                            .assign(to: &self.$databaseRecords)
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
}

// MARK: Request

extension BattleListViewModel {
    
    func requestBattleOverview() -> AnyPublisher<Data, APIError>  {
        Splatoon2API.battleInformation
            .request() // Not decode
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func requestBattleDetail(battleNumber: String) -> AnyPublisher<Data, APIError>  {
        Splatoon2API.result(battleNumber: battleNumber)
            .request() // Not decode
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

// MARK: Database

extension BattleListViewModel {
    
    /// Save original records json to database
    func saveRecordsData(_ data: Data, completed: @escaping (_ haveNewRecord: Bool) -> Void) {
        guard let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
        ) as? [String: AnyObject],
        let results = json["results"] as? [Dictionary<String, AnyObject>] else {
            return
        }
        
        let jsonResults = results.map { result -> String? in
            guard let data = try? JSONSerialization.data(withJSONObject: result, options: .sortedKeys),
                  let jsonString = String(data: data, encoding: .utf8) else {
                return nil
            }
            return jsonString
        }
        
        let battles = jsonResults.map { json -> SP2Battle? in
            guard let battle = json?.decode(SP2Battle.self) else {
                return nil
            }
            return battle
        }
        
        try! AppDatabase.shared.saveSampleBattles(jsonResults, battles: battles, completed: completed)
    }
    
    func updateRecordDetail(_ data: Data) {
        guard let detail = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
        ) as? [String: AnyObject] else {
            return
        }
        
        try! AppDatabase.shared.saveFullBattle(detail)
    }
    
}
