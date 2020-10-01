//
//  TabBarViewModel.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import Foundation
import Combine

class TabBarViewModel: ObservableObject {
    
    @Published var isLogin = false
    
    private var cancelBag = Set<AnyCancellable>()
    
    init() {
        isLogin = AppUserDefaults.shared.user != nil
    }
}
