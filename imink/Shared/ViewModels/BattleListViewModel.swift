//
//  BattleListViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/13.
//

import Foundation
import Combine

class BattleListViewModel: ObservableObject {
    @Published var records: [Record] = []
    @Published var isLoadingRealTimeBattle = false
    @Published var isLoadingDetail = false
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        // Load data from database
        updateReocrdsFromDatabase()
        
        // Sync battle detail to database
        $records
            .map { $0.filter { $0.id != -1 } }
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
            .map { (data: Data) -> Void in
                self.updateRecordDetail(data)
                return Void()
            }
            .throttle(for: 2.5, scheduler: DispatchQueue.main, latest: true)
            .sink { completion in
            } receiveValue: {
                self.updateReocrdsFromDatabase()
                
                if self.records.filter({ !$0.isDetail }).count == 0 {
                    self.isLoadingDetail = false
                }
            }
            .store(in: &cancelBag)
        
        startRealTimeDataLoop()
    }
    
    func startRealTimeDataLoop() {
        isLoadingRealTimeBattle = true
        syncResultsToDatabase {
            self.isLoadingRealTimeBattle = false
            
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
                        print(error.localizedDescription)
                    }
                }
                
            } receiveValue: { data in
                var haveNewRecord = false
                self.saveRecordsData(data, haveNewRecord: &haveNewRecord)
                if haveNewRecord {
                    self.updateReocrdsFromDatabase()
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
                    firstRecord.id = -1
                    self.records = [firstRecord] + records
                } else {
                    self.records = [
                        Record(
                            id: -1,
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
    
    /// Save original records json to database
    func saveRecordsData(_ data: Data, haveNewRecord: inout Bool) {
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
        
        try! AppDatabase.shared.saveSampleBattles(jsonResults, battles: battles, haveNewRecord: &haveNewRecord)
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
