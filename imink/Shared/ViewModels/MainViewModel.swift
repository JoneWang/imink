//
//  MainViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation
import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @Published var showHome = false
    
    private var cancelBag = Set<AnyCancellable>()

    init() {
        showHome = AppUserDefaults.shared.user != nil
        
        if showHome {
            // If logined update user
            requestUserInfo()
        }
    }
    
    func requestUserInfo() {
        AppAPI.me()
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
                }
            } receiveValue: { user in
                // Save new user information
                AppUserDefaults.shared.user = user
            }
            .store(in: &cancelBag)
    }
}
