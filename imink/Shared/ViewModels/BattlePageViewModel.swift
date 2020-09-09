//
//  BattlePageViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/5.
//

import Foundation
import Combine

enum BattleFetchError {
    case notUpdateBattle
}

class BattlePageViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var lastBattle: SP2Battle?
    
    private var cancelBag = Set<AnyCancellable>()

    init() {
        lastBattle = AppUserDefaults.shared.lastBattle
        
        startLoop()
    }

    func startLoop() {
        isLoading = true
        getLastBattle { battle in
            if let battle = battle {
                self.lastBattle = battle
                AppUserDefaults.shared.lastBattle = battle
            }
            self.isLoading = false

            // Next request after delayed for 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.startLoop()
            }
        }
    }
    
    func getLastBattle(_ finished: @escaping (SP2Battle?) -> Void) {
        requestBattleOverview()
            .filter {
                guard let lastBattle = self.lastBattle else {
                    return true
                }
                
                guard let number = $0.results.first?.battleNumber else {
                    finished(nil)
                    return false
                }
                
                let needUpdate = number != lastBattle.battleNumber
                if !needUpdate {
                    finished(nil)
                }
                return needUpdate
            }
            .flatMap { return self.requestResult(battleNumber: $0.results.first!.battleNumber) }
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
                    finished(nil)
                }
            } receiveValue: { battle in
                finished(battle)
            }
            .store(in: &cancelBag)
    }
    
    func requestBattleOverview() -> AnyPublisher<SP2BattleOverview, Error>  {
        Splatoon2API.battleInformation
            .request()
            .decode(type: SP2BattleOverview.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func requestResult(battleNumber: String) -> AnyPublisher<SP2Battle, Error> {
        Splatoon2API.result(battleNumber: battleNumber)
            .request()
            .decode(type: SP2Battle.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
