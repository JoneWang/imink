//
//  JobDetailViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/1/24.
//

import Foundation

class JobDetailViewModel {
    @Published var job: Job? = nil
    
    init(id: Int64) {
        let dbJob = AppDatabase.shared.job(with: id)
        self.job = dbJob?.job
    }
}
