//
//  SettingViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/5/30.
//

import Foundation

class SettingViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    
    @Published var exporting: Bool = false
    @Published var packingProgress: Double = 1
    
    init() {
        self.isLogined = AppUserDefaults.shared.sessionToken != nil
    }
    
    func logOut() {
        AppUserDefaults.shared.sessionToken = nil
    }
    
    func exportData(completed: @escaping (URL?) -> Void) {
        DataBackup.export { [weak self] finished, progress, exporting in
            self?.exporting = !finished
            self?.packingProgress = progress
            
            if (finished) {
                completed(exporting)
            }
        }
    }
}
