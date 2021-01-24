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
                dangerRate: job.dangerRate
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
                .fetchAll(db, sql: "SELECT id, sp2PrincipalId, jobId, isClear, gradePoint, gradePointDelta, gradeId, helpCount, deadCount, goldenIkuraNum, ikuraNum, failureWave, dangerRate  FROM job WHERE sp2PrincipalId = ? ORDER BY jobId DESC", arguments: [currentUser.sp2PrincipalId])
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
