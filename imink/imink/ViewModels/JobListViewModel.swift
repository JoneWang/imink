//
//  JobListViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import Foundation
import Combine
import os

class JobListViewModel: ObservableObject {
    
    @Published var rows: [DBJob] = []
    @Published var selectedId: Int64?
        
    init() {
        // Database records publisher
        AppDatabase.shared.jobs()
            .catch { error -> Just<[DBJob]> in
                os_log("Database Error: [jobs] \(error.localizedDescription)")
                return Just<[DBJob]>([])
            }
            .filter { _ in AppUserDefaults.shared.user != nil }
            .assign(to: &$rows)
    }
}
