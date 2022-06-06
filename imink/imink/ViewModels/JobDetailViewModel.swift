//
//  JobDetailViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/1/24.
//

import Foundation

class JobDetailViewModel: ObservableObject, Identifiable {
    
    @Published var job: Job? = nil
    
    let dbJob: DBJob
    
    var id: Int64? {
        dbJob.id
    }
    
    init(dbJob: DBJob) {
        self.dbJob = dbJob
    }
    
    func loadJob(sync: Bool = false) {
        guard let id = dbJob.id, self.job == nil else {
            return
        }
        
        if sync {
            let dbJob = AppDatabase.shared.job(with: id)
            self.job = dbJob?.job
        } else {
            DispatchQueue(label: "", qos: .background, attributes: .concurrent).async {
                let dbJob = AppDatabase.shared.job(with: id)
                DispatchQueue.main.async {
                    self.job = dbJob?.job
                }
            }
        }
    }
}
