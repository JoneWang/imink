//
//  SynchronizeViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/1/20.
//

import Foundation
import Combine
import os

class SynchronizeViewModel<I>: ObservableObject where I: Comparable {
    typealias IdType = I
    
    @Published var unsynchronizedIds: [IdType] = []
    
    @Published var isLogin: Bool = false
    @Published var autoRefresh = false
        
    var cancelBag = Set<AnyCancellable>()
    var syncCancelBag = Set<AnyCancellable>()
    
    init() {
        $autoRefresh
            .filter { $0 }
            .sink { [weak self] _ in
                self?.startRealTimeDataLoop()
            }
            .store(in: &cancelBag)
        
        $autoRefresh
            .filter { $0 }
            .sink { [weak self] _ in
                self?.syncDetails()
            }
            .store(in: &cancelBag)
        
        $isLogin.assign(to: &$autoRefresh)
    }
    
    func needSynchronizedIds(value: @escaping  ([IdType]) -> Void, finished: (() -> Void)?) { }
    
    func localUnsynchronizedIds(_ ids: [IdType]) -> [IdType] { [] }
    
    func requestDetail(id: IdType, finished: @escaping () -> Void) { }
    
    func loadingStatus(isLoading: Bool) { }
    
    func allFinished() { }
}

// MARK: Automatic data synchronization

extension SynchronizeViewModel {
    
    func startRealTimeDataLoop() {
        loadingStatus(isLoading: true)
        
        requestResults {
            if !self.autoRefresh { return }
            
            if self.unsynchronizedIds.count == 0 {
                self.loadingStatus(isLoading: false)
            }
            
            // Next request after delayed for 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                self.startRealTimeDataLoop()
            }
        }
    }
    
    func requestResults(finished: (() -> Void)? = nil) {
        needSynchronizedIds(value: { ids in
            if let firstId = ids.first,
               self.unsynchronizedIds.first != firstId {
                let unsynchronizedIds = self.localUnsynchronizedIds(ids).sorted { $0 < $1 }
                if unsynchronizedIds.count == 0 {
                    self.loadingStatus(isLoading: false)
                }
                
                self.unsynchronizedIds = unsynchronizedIds
            } else {
                self.loadingStatus(isLoading: false)
            }
        }, finished: finished)
    }
    
    func syncDetails() {
        syncCancelBag = Set<AnyCancellable>()
        
        $unsynchronizedIds
            .compactMap { $0.first }
            .sink(receiveValue: { [weak self] id in
                guard let `self` = self else { return }
                
                self.requestDetail(id: id) { [weak self] in
                    guard let `self` = self else { return }
                    
                    if self.unsynchronizedIds.count > 0 {
                        self.unsynchronizedIds.removeFirst()
                    }
                    
                    if self.unsynchronizedIds.count == 0 {
                        self.allFinished()
                        self.loadingStatus(isLoading: false)
                    }
                }
            })
            .store(in: &syncCancelBag)
    }
    
}
