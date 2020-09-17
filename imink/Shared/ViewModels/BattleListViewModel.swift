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
    @Published var isLoadingDetail = false
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        // Load data from database
        updateReocrdsFromDatabase()
        
        // Sync data from splatoon2 api
        requestBattleOverview()
            .sink { completion in
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
                self.saveRecordsData(data)
                self.updateReocrdsFromDatabase()
            }
            .store(in: &cancelBag)
        
        $records
            .filter { _ in !self.isLoadingDetail }
            .map { $0.filter { !$0.isDetail } }
            .filter {
                self.isLoadingDetail = $0.count > 0
                return self.isLoadingDetail
            }
            .map {
                $0.map {
                    self.requestBattleDetail(battleNumber: $0.battleNumber)
                }
            }
            .flatMap {
                $0.dropFirst().reduce($0.first!) {
                    $0.append($1).eraseToAnyPublisher()
                }
            }
            .sink { completion in
                self.isLoadingDetail = false
            } receiveValue: { data in
                self.updateRecordDetail(data)
                self.updateReocrdsFromDatabase()
            }
            .store(in: &cancelBag)
    }
    
    func updateReocrdsFromDatabase() {
        AppDatabase.shared.records()
            .catch { error in
                Just<[Record]>([])
            }
            .sink { records in
                self.records = records
            }
            .store(in: &cancelBag)
    }
    
    /// Save original records json to database
    func saveRecordsData(_ data: Data) {
        guard let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .mutableContainers
        ) as? [String: AnyObject],
        let results = json["results"] as? [Dictionary<String, AnyObject>] else {
            return
        }
        
        try! AppDatabase.shared.saveSampleBattles(results)
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
