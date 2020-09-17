//
//  LaunchViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import Foundation
import SwiftUI
import Combine

class LaunchPageViewModel: ObservableObject {
    enum Status {
        case needToken
        case loading
        case loginSuccess
    }
    
    @Published var status: Status? = .needToken
    @Published var inputClientToken: String = ""
    @Published var clientToken: String? = nil
    @Published var loginUser: User? = nil
    
    private var cancelBag = Set<AnyCancellable>()
    
    func login() {
        status = .loading
        
        AppAPI.me(clientToken: inputClientToken)
            .request()
            .decode(type: User.self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let `self` = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // TODO: Popping error view
                    print(error.localizedDescription)
                    self.status = .needToken
                }
            } receiveValue: { [weak self] user in
                guard let `self` = self else { return }
                
                // Save Client Token
                print(self.inputClientToken)
                
                self.clientToken = self.inputClientToken
                self.loginUser = user
                self.status = .loginSuccess
                
                AppUserDefaults.shared.clientToken = self.clientToken
                AppUserDefaults.shared.user = user
            }
            .store(in: &cancelBag)
    }
}
