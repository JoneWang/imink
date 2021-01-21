//
//  SynchronizeBattleViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/1/20.
//

import Foundation
import Combine
import os

class SynchronizeBattleViewModel: SynchronizeViewModel<String> {
    
    override func needSynchronizedIds(value: @escaping ([String]) -> Void, finished: (() -> Void)?) {
        Splatoon2API.battleInformation
            .request() // Not decode
            .decode(type: BattleOverview.self)
            .receive(on: DispatchQueue.main)
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
            } receiveValue: { battleOverview in
                let battleIds = battleOverview.results.map { $0.battleNumber }
                value(battleIds)
            }
            .store(in: &super.cancelBag)
    }
    
    override func localUnsynchronizedIds(_ ids: [String]) -> [String] {
        AppDatabase.shared.unsynchronizedBattleIds(with: ids)
    }
    
    override func requestDetail(id: String) -> AnyPublisher<Data, Never> {
        Splatoon2API.result(battleNumber: id)
            .request() // Not decode
            .receive(on: DispatchQueue.main)
            .catch { error -> Just<Data> in
                os_log("API Error: [splatoon2/results/id] \(error.localizedDescription)")
                return Just<Data>(Data())
            }
            .map { data -> Data in
                AppDatabase.shared.saveBattle(data: data)
                return data
            }
            .eraseToAnyPublisher()
    }
    
    override func loadingStatus(isLoading: Bool) {
        NotificationCenter.default.post(
            name: .isLoadingRealTimeBattleResult,
            object: isLoading
        )
    }
    
    override func allFinished() {
        NotificationCenter.default.post(name: .recordSyncDetailFinished, object: nil)
    }
}
