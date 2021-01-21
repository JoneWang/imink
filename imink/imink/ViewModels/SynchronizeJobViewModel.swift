//
//  SynchronizeJobViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/1/20.
//

import Foundation
import Combine
import os

class SynchronizeJobViewModel: SynchronizeViewModel<Int> {
    
    override func needSynchronizedIds(value: @escaping ([Int]) -> Void, finished: (() -> Void)?) {
        Splatoon2API.jobOverview
            .request() // Not decode
            .decode(type: JobOverview.self)
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
            } receiveValue: { jobOverview in
                let jobIds = jobOverview.results.map { $0.jobId }
                value(jobIds)
            }
            .store(in: &super.cancelBag)
    }
    
    override func localUnsynchronizedIds(_ ids: [Int]) -> [Int] {
        AppDatabase.shared.unsynchronizedJobIds(with: ids)
    }
    
    override func requestDetail(id: Int) -> AnyPublisher<Data, Never> {
        Splatoon2API.job(id: id)
            .request() // Not decode
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .catch { error -> Just<Data> in
                os_log("API Error: [splatoon2/job/id] \(error.localizedDescription)")
                return Just<Data>(Data())
            }
            .map { data -> Data in
                AppDatabase.shared.saveJob(data: data)
                return data
            }
            .eraseToAnyPublisher()
    }
    
    override func loadingStatus(isLoading: Bool) { }
    
    override func allFinished() { }
}
