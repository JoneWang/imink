//
//  JobListViewModel.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import Foundation
import Combine
import os

struct JobListRowModel: Identifiable {
    
    let type: RowType
    var job: DBJob?
    var shiftCard: ShiftCard?
    
    var id: String {
        switch type {
        case .job:
            return "\(job!.id!)\(type.rawValue)"
        case .shiftCard:
            return "\(shiftCard!.scheduleStartTime)\(type.rawValue)"
        }
    }
    
    var dbId: Int64 {
        job?.id ?? 0
    }
    
    enum RowType: String {
        case shiftCard, job
    }
    
    struct ShiftCard {
        var scheduleStartTime: Date
        var scheduleEndTime: Date
        var scheduleStageName: String
        var scheduleWeapon1Id: String
        var scheduleWeapon1Image: String
        var scheduleWeapon2Id: String
        var scheduleWeapon2Image: String
        var scheduleWeapon3Id: String
        var scheduleWeapon3Image: String
        var scheduleWeapon4Id: String
        var scheduleWeapon4Image: String
        var totalClearCount: Int = 0
        var totalHelpCount: Int = 0
        var totalGoldenIkuraCount: Int = 0
        var totalDeadCount: Int = 0
        var gameCount: Int = 0
    }
}

extension JobListRowModel: Equatable {
    static func == (lhs: JobListRowModel, rhs: JobListRowModel) -> Bool {
        lhs.id == rhs.id
    }
}

class JobListViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    @Published var rows: [JobListRowModel] = []
    @Published var selectedId: Int64?
    
    @Published var databaseDBJobs: [DBJob] = []

    private var cancelBag = Set<AnyCancellable>()

    init() {
        let isLogined = AppUserDefaults.shared.sessionToken != nil
        updateLoginStatus(isLogined: isLogined)
    }
    
    func updateLoginStatus(isLogined: Bool) {
        cancelBag = Set<AnyCancellable>()
        
        self.isLogined = isLogined
        
        if !isLogined {
            rows = []
            selectedId = nil
            return
        }
        
        // Database records publisher
        AppDatabase.shared.jobs()
            .catch { error -> Just<[DBJob]> in
                os_log("Database Error: [jobs] \(error.localizedDescription)")
                return Just<[DBJob]>([])
            }
            .assign(to: \.databaseDBJobs, on: self)
            .store(in: &cancelBag)
        
        $databaseDBJobs
            .map { jobs in
                var rows = [JobListRowModel]()
                var lastStartTime: Date?
                var lastRowModel: JobListRowModel?
                for job in jobs {
                    rows.append(JobListRowModel(type: .job, job: job))
                    
                    if lastStartTime == nil ||
                        (lastStartTime != nil && lastStartTime != job.scheduleStartTime) ||
                        jobs.last == job {
                        if var rowModel = lastRowModel {
                            
                            if jobs.last == job {
                                rowModel.shiftCard!.totalClearCount += (job.failureWave ?? 4) - 1
                                rowModel.shiftCard!.totalHelpCount += job.helpCount
                                rowModel.shiftCard!.totalGoldenIkuraCount += job.goldenIkuraNum
                                rowModel.shiftCard!.totalDeadCount += job.deadCount
                                rowModel.shiftCard!.gameCount += 1
                                rows.insert(rowModel, at: rows.count - rowModel.shiftCard!.gameCount)
                                
                                break
                            } else {
                                rows.insert(rowModel, at: rows.count - (rowModel.shiftCard!.gameCount + 1))
                            }
                            
                            lastRowModel = nil
                        }
                        
                        if lastRowModel == nil {
                            let shiftCard = JobListRowModel.ShiftCard(
                                scheduleStartTime: job.scheduleStartTime,
                                scheduleEndTime: job.scheduleEndTime,
                                scheduleStageName: job.scheduleStageName,
                                scheduleWeapon1Id: job.scheduleWeapon1Id,
                                scheduleWeapon1Image: job.scheduleWeapon1Image,
                                scheduleWeapon2Id: job.scheduleWeapon2Id,
                                scheduleWeapon2Image: job.scheduleWeapon2Image,
                                scheduleWeapon3Id: job.scheduleWeapon3Id,
                                scheduleWeapon3Image: job.scheduleWeapon3Image,
                                scheduleWeapon4Id: job.scheduleWeapon4Id,
                                scheduleWeapon4Image: job.scheduleWeapon4Image
                            )
                            lastRowModel = JobListRowModel(type: .shiftCard, shiftCard: shiftCard)
                        }
                    }
                    
                    lastRowModel!.shiftCard!.totalClearCount += (job.failureWave ?? 4) - 1
                    lastRowModel!.shiftCard!.totalHelpCount += job.helpCount
                    lastRowModel!.shiftCard!.totalGoldenIkuraCount += job.goldenIkuraNum
                    lastRowModel!.shiftCard!.totalDeadCount += job.deadCount
                    lastRowModel!.shiftCard!.gameCount += 1
                    
                    lastStartTime = job.scheduleStartTime
                }
                return rows
            }
            .assign(to: \.rows, on: self)
            .store(in: &cancelBag)
    }
}
