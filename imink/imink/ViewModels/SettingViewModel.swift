//
//  SettingViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/5/30.
//

import Foundation

class SettingViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    
    init() {
        self.isLogined = AppUserDefaults.shared.sessionToken != nil
    }
    
    func logOut() {
        AppUserDefaults.shared.sessionToken = nil
    }
}
