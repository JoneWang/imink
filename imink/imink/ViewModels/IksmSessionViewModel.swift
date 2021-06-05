//
//  IksmSessionViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/5/30.
//

import Foundation
import Combine

class IksmSessionViewModel: ObservableObject {
    
    @Published var iksmSessionIsValid: Bool = false
    @Published var isRenewing: Bool = false
    @Published var renewAlert: Bool = false
    @Published var needManualRenew: Bool = false
    
    private var cancelBag: Set<AnyCancellable>!
    
    init() {
        let isLogined = AppUserDefaults.shared.sessionToken != nil
        updateLoginStatus(isLogined: isLogined)
    }
    
    func updateLoginStatus(isLogined: Bool) {
        cancelBag = Set<AnyCancellable>()
        
        if !isLogined {
            iksmSessionIsValid = false
            isRenewing = false
            renewAlert = false
            needManualRenew = false
            return
        }
        
        IksmSessionManager.shared.isValidPublisher
            .assign(to: \.iksmSessionIsValid, on: self)
            .store(in: &cancelBag)
        
        IksmSessionManager.shared.isRenewingPublisher
            .assign(to: \.isRenewing, on: self)
            .store(in: &cancelBag)
        
        IksmSessionManager.shared.renewResultPublisher
            .map { $0 != nil }
            .assign(to: \.renewAlert, on: self)
            .store(in: &cancelBag)
        
        IksmSessionManager.shared.needManualRenewPublisher
            .assign(to: \.needManualRenew, on: self)
            .store(in: &cancelBag)
    }
    
    func renew() {
        IksmSessionManager.shared.renew()
    }
}
