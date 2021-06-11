//
//  IksmSessionManager.swift
//  imink
//
//  Created by Jone Wang on 2021/5/30.
//

import Foundation
import Combine
import os

class IksmSessionManager {
    static let shared = IksmSessionManager()
    
    private var firstRenewFailedAfterLaunchSubject = CurrentValueSubject<Bool, Never>(false)
    private var needManualRenewSubject = CurrentValueSubject<Bool, Never>(true)
    private var isRenewingSubject = CurrentValueSubject<Bool, Never>(false)
    private var isValidSubject: CurrentValueSubject<Bool, Never>
    private var renewResultSubject = PassthroughSubject<Error?, Never>()
    
    private static var isValid: Bool {
        let sessionCookie = HTTPCookieStorage.appGroup.cookies?
            .first(where: { $0.name == "iksm_session" })
        if let expiresDate = sessionCookie?.expiresDate {
            return expiresDate > Date()
        } else {
            return false
        }
    }
    
    var isValid: Bool {
        IksmSessionManager.isValid
    }
    
    var cancelBag: Set<AnyCancellable>
    
    init() {
        cancelBag = Set<AnyCancellable>()
        
        isValidSubject = CurrentValueSubject<Bool, Never>(IksmSessionManager.isValid)
    }
    
    func renew(launch: Bool = false) {
        guard let sessionToken = AppUserDefaults.shared.sessionToken else {
            isRenewingSubject.value = false
            return
        }
        
        if isRenewingSubject.value {
            return
        }
        
        if launch {
            needManualRenewSubject.value = false
        }
        isRenewingSubject.value = true
        NSOHelper.getIKsmSession(sessionToken: sessionToken)
            .sink { completion in
                self.isRenewingSubject.value = false
                
                switch completion {
                case .finished:
                    self.renewResultSubject.send(nil)
                    self.needManualRenewSubject.value = false
                    break
                case .failure(let error):
                    if case NSOError.sessionTokenInvalid = error {
                        AppUserDefaults.shared.sessionToken = nil
                    } else {
                        if !launch {
                            self.renewResultSubject.send(error)
                        }
                        self.needManualRenewSubject.value = true
                        os_log("API Error: [getIKsmSession] \(error.localizedDescription)")
                    }
                }
            } receiveValue: { _ in
                self.isValidSubject.value = true
            }
            .store(in: &cancelBag)
    }

    func clear(iksmSession: String? = nil) {
        let cookieStorage = HTTPCookieStorage.appGroup
        if let sessionCookie = cookieStorage.cookies?
            .first(where: { $0.name == "iksm_session" && (iksmSession == nil || $0.value == iksmSession) }) {
            cookieStorage.deleteCookie(sessionCookie)
        }
        
        DispatchQueue.main.async {
            self.isValidSubject.value = false
        }
    }
    
    func refresh() {
        isValidSubject.value = IksmSessionManager.isValid
    }
}

extension IksmSessionManager {
    func activateIksmSession() {
        if let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId, isValid {
            Splatoon2API.nicknameAndIcon(id: sp2PrincipalId)
                .request()
                .receive(on: DispatchQueue.main)
                .sink { _ in
                } receiveValue: { (data: Data) in
                }
                .store(in: &cancelBag)
        }
    }
}

extension IksmSessionManager {
    var firstRenewFailedAfterLaunchPublisher: AnyPublisher<Bool, Never> {
        firstRenewFailedAfterLaunchSubject.eraseToAnyPublisher()
    }
    
    var isRenewingPublisher: AnyPublisher<Bool, Never> {
        isRenewingSubject.eraseToAnyPublisher()
    }
    
    var isValidPublisher: AnyPublisher<Bool, Never> {
        isValidSubject.eraseToAnyPublisher()
    }
    
    var renewResultPublisher: AnyPublisher<Error?, Never> {
        renewResultSubject.eraseToAnyPublisher()
    }
    
    var needManualRenewPublisher: AnyPublisher<Bool, Never> {
        needManualRenewSubject.eraseToAnyPublisher()
    }
}
