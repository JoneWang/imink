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
    @Published var clientToken: String = ""
    
    private var cancelBag = Set<AnyCancellable>()

    init() { }
    
    func login() {
        status = .loading
        
        AppAPI.me(clientToken: clientToken)
            .request()
            .decode(type: User.self)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // TODO: Popping error view
                    print(error.localizedDescription)
                    self.status = .needToken
                }
            } receiveValue: { user in
                self.status = .loginSuccess
                // Save Client Token
                AppUserDefaults.shared.clientToken = self.clientToken
                AppUserDefaults.shared.user = user
            }
            .store(in: &cancelBag)
    }
}
