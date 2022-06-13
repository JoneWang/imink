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

extension DBJob {
    static func load(data: Data) -> DBJob? {
        guard let json = String(data: data, encoding: .utf8),
              let job = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
              let myResult = job["my_result"] as? [String: Any],
              let jobResult = job["job_result"] as? [String: Any],
              let grade = job["grade"] as? [String: Any],
              let schedule = job["schedule"] as? [String: Any],
              let weapons = schedule["weapons"] as? [[String: Any]],
              
              let sp2PrincipalId = myResult["pid"] as? String,
              let jobId = job["job_id"] as? Int,
              let isClear = jobResult["is_clear"] as? Bool,
              let gradePoint = job["grade_point"] as? Int,
              let gradePointDelta = job["grade_point_delta"] as? Int,
              let gradeId = grade["id"] as? String,
              let helpCount = myResult["help_count"] as? Int,
              let deadCount = myResult["dead_count"] as? Int,
              let goldenIkuraNum = myResult["golden_ikura_num"] as? Int,
              let ikuraNum = myResult["ikura_num"] as? Int,
              let dangerRate = job["danger_rate"] as? Double,
              let scheduleStartTimestamp = schedule["start_time"] as? Double,
              let scheduleEndTimestamp = schedule["end_time"] as? Double
        else {
            return nil
        }
        
        let failureWave = jobResult["failure_wave"] as? Int
        let stage = schedule["stage"] as? [String: Any]
        let scheduleStageName = stage?["name"] as? String
        
        let weapon1 = weapons[0]["weapon"] as? [String: Any]
        let weapon2 = weapons[1]["weapon"] as? [String: Any]
        let weapon3 = weapons[2]["weapon"] as? [String: Any]
        let weapon4 = weapons[3]["weapon"] as? [String: Any]
        
        let scheduleWeapon1Id = weapons[0]["id"] as? String
        let scheduleWeapon1Image = weapon1?["image"] as? String
        let scheduleWeapon2Id = weapons[1]["id"] as? String
        let scheduleWeapon2Image = weapon2?["image"] as? String
        let scheduleWeapon3Id = weapons[2]["id"] as? String
        let scheduleWeapon3Image = weapon3?["image"] as? String
        let scheduleWeapon4Id = weapons[3]["id"] as? String
        let scheduleWeapon4Image = weapon4?["image"] as? String

        return DBJob(
            sp2PrincipalId: sp2PrincipalId,
            jobId: jobId,
            json: json,
            isClear: isClear,
            gradePoint: gradePoint,
            gradePointDelta: gradePointDelta,
            gradeId: gradeId,
            helpCount: helpCount,
            deadCount: deadCount,
            goldenIkuraNum: goldenIkuraNum,
            ikuraNum: ikuraNum,
            failureWave: failureWave,
            dangerRate: dangerRate,
            scheduleStartTime: Date(timeIntervalSince1970: scheduleStartTimestamp),
            scheduleEndTime: Date(timeIntervalSince1970: scheduleEndTimestamp),
            scheduleStageName: scheduleStageName ?? "",
            scheduleWeapon1Id: scheduleWeapon1Id ?? "",
            scheduleWeapon1Image: scheduleWeapon1Image ?? "",
            scheduleWeapon2Id: scheduleWeapon2Id ?? "",
            scheduleWeapon2Image: scheduleWeapon2Image ?? "",
            scheduleWeapon3Id: scheduleWeapon3Id ?? "",
            scheduleWeapon3Image: scheduleWeapon3Image ?? "",
            scheduleWeapon4Id: scheduleWeapon4Id ?? "",
            scheduleWeapon4Image: scheduleWeapon4Image ?? ""
        )
    }
}

extension AppDatabase {
    
    // MARK: Writes
    
#if DEBUG
    func removeAllJobs() {
        dbQueue.asyncWrite { db in
            try DBJob.deleteAll(db)
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [removeAllJobs] \(error.localizedDescription)")
            }
        }
    }
    
    func removeJobs(count: Int) {
        dbQueue.asyncWrite { db in
            try DBJob
                .order(DBJob.Columns.jobId.desc)
                .limit(count)
                .deleteAll(db)
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [removeJobs] \(error.localizedDescription)")
            }
        }
    }
#endif
    
    func saveJob(data: Data) {
        dbQueue.asyncWrite { db in
            if let job = DBJob.load(data: data) {
                _ = try self.saveJob(db: db, job: job)
            }
        } completion: { _, error in
            if case let .failure(error) = error {
                os_log("Database Error: [saveJob] \(error.localizedDescription)")
            }
        }
    }
    
    func saveJobs(jobs: [DBJob], progress: @escaping ((Double, Int, Error?) -> Void)) {
        dbQueue.asyncWrite { db in
            var saveCount = 0
            for (i, job) in jobs.enumerated() {
                if try self.saveJob(db: db, job: job) {
                    saveCount += 1
                }
                progress(Double(i + 1) / Double(jobs.count), saveCount, nil)
            }
        } completion: { _, result in
            if case let .failure(error) = result {
                progress(1, 0, error)
                os_log("Database Error: [saveJob] \(error.localizedDescription)")
            }
        }
    }
    
    private func saveJob(db: Database, job: DBJob) throws -> Bool {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId,
              job.sp2PrincipalId == sp2PrincipalId else {
            return false
        }
        
        if try DBJob.filter(
            DBJob.Columns.sp2PrincipalId == sp2PrincipalId &&
                DBJob.Columns.jobId == job.jobId
        ).fetchCount(db) > 0 {
            return false
        }
        
        var job = job
        try job.insert(db)
        
        return true
    }
    
    // MARK: Reads
    
    func jobs() -> AnyPublisher<[DBJob], Error> {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return Just<[DBJob]>([])
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        return ValueObservation.tracking { db in
            // exclude json
            try Row
                .fetchAll(db, sql: "SELECT id, sp2PrincipalId, jobId, isClear, gradePoint, gradePointDelta, gradeId, helpCount, deadCount, goldenIkuraNum, ikuraNum, failureWave, dangerRate, scheduleStartTime, scheduleEndTime, scheduleStageName, scheduleWeapon1Id, scheduleWeapon1Image, scheduleWeapon2Id, scheduleWeapon2Image, scheduleWeapon3Id, scheduleWeapon3Image, scheduleWeapon4Id, scheduleWeapon4Image FROM job WHERE sp2PrincipalId = ? ORDER BY jobId DESC", arguments: [sp2PrincipalId])
                .map { row in
                    DBJob(row: row)
                }
        }
        .publisher(in: dbQueue, scheduling: .immediate)
        .eraseToAnyPublisher()
    }
    
    func jobs(start jobId: Int? = nil, count: Int) -> [DBJob] {
        return try! dbQueue.read { db in
            if let jobId = jobId {
                return try! DBJob
                    .filter(DBJob.Columns.jobId < jobId)
                    .order(DBJob.Columns.jobId.desc)
                    .limit(count)
                    .fetchAll(db)
            } else {
                return try! DBJob
                    .order(DBJob.Columns.jobId.desc)
                    .limit(count)
                    .fetchAll(db)
            }
        }
    }
    
    func unsynchronizedJobIds(with jobIds: [Int]) -> [Int] {
        guard let sp2PrincipalId = AppUserDefaults.shared.sp2PrincipalId else {
            return []
        }
        
        return try! dbQueue.read { db in
            let alreadyExistsRecords = try! DBJob.filter(
                DBJob.Columns.sp2PrincipalId == sp2PrincipalId &&
                    jobIds.contains(DBJob.Columns.jobId)
            )
            .fetchAll(db)
            
            let alreadyExistsIds = alreadyExistsRecords.map { $0.jobId }
            let unsynchronizedIds = Array(Set(jobIds).subtracting(Set(alreadyExistsIds)))
            
            return unsynchronizedIds
        }
    }
    
    func job(with id: Int64) -> DBJob? {
        return try! dbQueue.read { db in
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
