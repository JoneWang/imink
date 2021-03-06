//
//  DBJob.swift
//  imink
//
//  Created by Jone Wang on 2021/1/20.
//

import Foundation
import GRDB
import Combine
import os

struct DBJob: Identifiable {
    
    // MARK: Column
    
    var id: Int64?
    var sp2PrincipalId: String
    var jobId: Int
    var json: String?
    
    var isClear: Bool
    var gradePoint: Int
    var gradePointDelta: Int
    var gradeId: String
    var helpCount: Int
    var deadCount: Int
    var goldenIkuraNum: Int
    var ikuraNum: Int
    var failureWave: Int?
    var dangerRate: Double
    
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
}

extension DBJob: Equatable { }

extension DBJob: Codable, FetchableRecord, MutablePersistableRecord {
    
    // Table name
    static let databaseTableName = "job"
    
    // Define database columns from CodingKeys
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let sp2PrincipalId = Column(CodingKeys.sp2PrincipalId)
        static let jobId = Column(CodingKeys.jobId)
        static let json = Column(CodingKeys.json)
        static let isClear = Column(CodingKeys.isClear)
        static let gradePoint = Column(CodingKeys.gradePoint)
        static let gradePointDelta = Column(CodingKeys.gradePointDelta)
        static let gradeId = Column(CodingKeys.gradeId)
        static let helpCount = Column(CodingKeys.helpCount)
        static let deadCount = Column(CodingKeys.deadCount)
        static let goldenIkuraNum = Column(CodingKeys.goldenIkuraNum)
        static let ikuraNum = Column(CodingKeys.ikuraNum)
        static let failureWave = Column(CodingKeys.failureWave)
        static let dangerRate = Column(CodingKeys.dangerRate)
        static let scheduleStartTime = Column(CodingKeys.scheduleStartTime)
        static let scheduleEndTime = Column(CodingKeys.scheduleEndTime)
        static let scheduleStageName = Column(CodingKeys.scheduleStageName)
        static let scheduleWeapon1Id = Column(CodingKeys.scheduleWeapon1Id)
        static let scheduleWeapon1Image = Column(CodingKeys.scheduleWeapon1Image)
        static let scheduleWeapon2Id = Column(CodingKeys.scheduleWeapon2Id)
        static let scheduleWeapon2Image = Column(CodingKeys.scheduleWeapon2Image)
        static let scheduleWeapon3Id = Column(CodingKeys.scheduleWeapon3Id)
        static let scheduleWeapon3Image = Column(CodingKeys.scheduleWeapon3Image)
        static let scheduleWeapon4Id = Column(CodingKeys.scheduleWeapon4Id)
        static let scheduleWeapon4Image = Column(CodingKeys.scheduleWeapon4Image)
    }
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension AppDatabase {
    
    // MARK: Writes
    
    func removeAllJobs() {
        dbQueue.asyncWrite { db in
            try DBJob.deleteAll(db)
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [removeAllJobs] \(error.localizedDescription)")
            }
        }
    }
    
    func saveJob(data: Data) {
        guard let currentUser = AppUserDefaults.shared.user,
              let jsonString = String(data: data, encoding: .utf8),
              let job = jsonString.decode(Job.self) else {
            return
        }
        
        dbQueue.asyncWrite { db in
            if try DBJob.filter(
                DBJob.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                    DBJob.Columns.jobId == job.jobId
            ).fetchCount(db) > 0 {
                return
            }
            
            var record = DBJob(
                sp2PrincipalId: currentUser.sp2PrincipalId,
                jobId: job.jobId,
                json: jsonString,
                isClear: job.jobResult.isClear,
                gradePoint: job.gradePoint,
                gradePointDelta: job.gradePointDelta,
                gradeId: job.grade.id,
                helpCount: job.myResult.helpCount,
                deadCount: job.myResult.deadCount,
                goldenIkuraNum: job.myResult.goldenIkuraNum,
                ikuraNum: job.myResult.ikuraNum,
                failureWave: job.jobResult.failureWave,
                dangerRate: job.dangerRate,
                scheduleStartTime: job.schedule.startTime,
                scheduleEndTime: job.schedule.endTime,
                scheduleStageName: job.schedule.stage?.name ?? "",
                scheduleWeapon1Id: job.schedule.weapons?[0].id ?? "",
                scheduleWeapon1Image: job.schedule.weapons?[0].weapon?.$image ?? "",
                scheduleWeapon2Id: job.schedule.weapons?[1].id ?? "",
                scheduleWeapon2Image: job.schedule.weapons?[1].weapon?.$image ?? "",
                scheduleWeapon3Id: job.schedule.weapons?[2].id ?? "",
                scheduleWeapon3Image: job.schedule.weapons?[2].weapon?.$image ?? "",
                scheduleWeapon4Id: job.schedule.weapons?[3].id ?? "",
                scheduleWeapon4Image: job.schedule.weapons?[3].weapon?.$image ?? ""
                )
            try record.insert(db)
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveJob] \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: Reads
    
    func jobs() -> AnyPublisher<[DBJob], Error> {
        guard let currentUser = AppUserDefaults.shared.user else {
            return Just<[DBJob]>([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation.tracking { db in
            // exclude json
            try Row
                .fetchAll(db, sql: "SELECT id, sp2PrincipalId, jobId, isClear, gradePoint, gradePointDelta, gradeId, helpCount, deadCount, goldenIkuraNum, ikuraNum, failureWave, dangerRate, scheduleStartTime, scheduleEndTime, scheduleStageName, scheduleWeapon1Id, scheduleWeapon1Image, scheduleWeapon2Id, scheduleWeapon2Image, scheduleWeapon3Id, scheduleWeapon3Image, scheduleWeapon4Id, scheduleWeapon4Image FROM job WHERE sp2PrincipalId = ? ORDER BY jobId DESC", arguments: [currentUser.sp2PrincipalId])
                .map { row in
                    DBJob(row: row)
                }
        }
        .publisher(in: dbQueue, scheduling: .immediate)
        .eraseToAnyPublisher()
    }
    
    func unsynchronizedJobIds(with jobIds: [Int]) -> [Int] {
        guard let currentUser = AppUserDefaults.shared.user else {
            return []
        }
        
        return dbQueue.read { db in
            let alreadyExistsRecords = try! DBJob.filter(
                DBJob.Columns.sp2PrincipalId == currentUser.sp2PrincipalId &&
                    jobIds.contains(DBJob.Columns.jobId)
            )
            .fetchAll(db)
            
            let alreadyExistsIds = alreadyExistsRecords.map { $0.jobId }
            let unsynchronizedIds = Array(Set(jobIds).subtracting(Set(alreadyExistsIds)))
            
            return unsynchronizedIds
        }
    }
    
    func job(with id: Int64) -> DBJob? {
        return dbQueue.read { db in
            return try? DBJob
                .filter(DBJob.Columns.id == id)
                .fetchOne(db)
        }
    }
}

extension DBJob {
    var job: Job? {
        json?.decode(Job.self)
    }
}
