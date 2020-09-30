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
    @Published var isLoadingDetail = false
    @Published var autoRefresh = false
    @Published var isLogin = false
    
    private var cancelBag = Set<AnyCancellable>()
    
    private var requestDetailCancellable: AnyCancellable!
    
    init() {
        // Load data from database
        updateReocrdsFromDatabase()
        
        syncBattleDetail()
        
        $autoRefresh
            .sink { [weak self] isAutoRefresh in
                if isAutoRefresh {
                    self?.startRealTimeDataLoop()
                }
            }
            .store(in: &cancelBag)
        
        $isLogin
            .sink { [weak self] in
                self?.autoRefresh = $0
            }
            .store(in: &cancelBag)
        
        isLogin = AppUserDefaults.shared.user != nil
    }
    
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
                self.saveRecordsData(data) { [weak self] haveNewRecord in
                    guard let `self` = self else { return }
                    
                    if haveNewRecord {
                        self.updateReocrdsFromDatabase()
                    } else if self.records.filter({ !$0.isDetail }).count > 0 && !self.isLoadingDetail {
                        // Trigger detail request
                        self.syncBattleDetail()
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
    func updateReocrdsFromDatabase() {
        AppDatabase.shared.records()
            .catch { error in
                Just<[Record]>([])
            }
            .sink { records in
                if let firstRecord = records.first {
                    var firstRecord = firstRecord.copy()
                    firstRecord.id = nil
                    self.records = [firstRecord] + records
                } else {
                    self.records = [
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
            .store(in: &cancelBag)
    }
    
    /// Sync battle detail to database
    func syncBattleDetail() {
        requestDetailCancellable = $records
            .map { $0.filter { $0.id != nil } }
            .filter { _ in !self.isLoadingDetail }
            .map { $0.filter { !$0.isDetail } }
            .filter {
                self.isLoadingDetail = $0.count > 0
                return self.isLoadingDetail
            }
            .map {
                $0.map { self.requestBattleDetail(battleNumber: $0.battleNumber) }
            }
            .flatMap {
                $0.dropFirst().reduce($0.first!) {
                    $0.append($1).eraseToAnyPublisher()
                }
            }
            .map { data -> (String?, SP2Battle?) in
                self.updateRecordDetail(data)
                let json = String(data: data, encoding: .utf8)
                let battle = json?.decode(SP2Battle.self)
                return (json, battle)
            }
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.isLoadingDetail = false
                    os_log("API Error: [splatoon2/battles/id] \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] (json, battle) in
                guard let `self` = self else { return }
                // Update records
                if let battle = battle, let json = json,
                    let index = self.records.firstIndex(
                        where: { $0.id != nil && $0.battleNumber == battle.battleNumber }
                    ) {
                    var record = self.records[index]
                    record.json = json
                    record.isDetail = true
                    self.records[index] = record
                    
                    if index == 1 {
                        var record = self.records[0]
                        record.json = json
                        record.isDetail = true
                        self.records[0] = record
                    }
                }
                
                if self.records.filter({ !$0.isDetail }).count == 0 {
                    self.isLoadingDetail = false
                }
            }
    }
    
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
