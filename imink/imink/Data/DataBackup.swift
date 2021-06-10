//
//  DataBackup.swift
//  imink
//
//  Created by Jone Wang on 2021/6/3.
//

import Foundation
import Combine
import Zip
import os

enum DataBackupError: Error {
    case unknownError
    case databaseWriteError
    case invalidDirectoryStructure
}

extension DataBackupError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknownError:
            return "Unknown error"
        case .databaseWriteError:
            return "Database write error"
        case .invalidDirectoryStructure:
            return "Invalid directory structure"
        }
    }
}

struct DataBackupProgress {
    let unzipProgressScale = 0.5
    let loadFilesProgressScale = 0.3
    var importBattlesProgressScale = 0.15
    var importJobsProgressScale = 0.05
    
    var unzipProgress: Double = 0
    var loadFilesProgress: Double = 0
    var importBattlesProgress: Double = 0
    var importBattlesCount: Int = 0
    var importJobsProgress: Double = 0
    var importJobsCount: Int = 0
    
    var value: Double {
        unzipProgress * unzipProgressScale +
            loadFilesProgress * loadFilesProgressScale +
            importBattlesProgress * importBattlesProgressScale +
            importJobsProgress * importJobsProgressScale
    }
    
    var count: Int {
        importBattlesCount + importJobsCount
    }
}

class DataBackup {
    static let shared = DataBackup()
    
    private var importProgress = DataBackupProgress()
    private var importError: DataBackupError? = nil
    
    private var progressCancellable: AnyCancellable?
}

// MARK: Export

extension DataBackup {
    
    func export(progress: @escaping (Bool, Double, URL?) -> Void) {
        progress(false, 0, nil)
        let queue = DispatchQueue(label: "PackingData")
        queue.async {
            let exportPath = try? self.packingData { value in
                DispatchQueue.main.async {
                    progress(false, value, nil)
                }
            }
            DispatchQueue.main.async {
                progress(true, 1, exportPath)
            }
        }
    }
    
    private func packingData(progress: @escaping (Double) -> Void) throws -> URL {
        
        try removeTemporaryFiles()
        
        let fileManager = FileManager()
        let temporaryPath = fileManager.temporaryDirectory
        
        let exportPath = temporaryPath.appendingPathComponent("imink_export")
        let zipPath = temporaryPath.appendingPathComponent("imink_export.zip")
        
        let records = AppDatabase.shared.records(count: Int.max)
        let jobs = AppDatabase.shared.jobs(count: Int.max)
        
        let exportTotalCount = records.count + jobs.count
        var exportedCount = 0
        
        // Export battles
        let battlePath = exportPath.appendingPathComponent("battle")
        try fileManager.createDirectory(at: battlePath, withIntermediateDirectories: true, attributes: nil)
        
        for record in records {
            exportedCount += 1
            progress((Double(exportedCount) / Double(exportTotalCount)) * 0.3)
            
            let filePath = battlePath.appendingPathComponent("\(record.battleNumber).json")
            guard let json = record.json else { continue }
            try json.write(to: filePath, atomically: false, encoding: .utf8)
        }
        
        // Export jobs
        let salmonRunPath = exportPath.appendingPathComponent("salmonrun")
        try fileManager.createDirectory(at: salmonRunPath, withIntermediateDirectories: true, attributes: nil)
        
        for job in jobs {
            exportedCount += 1
            progress((Double(exportedCount) / Double(exportTotalCount)) * 0.3)
            
            let filePath = salmonRunPath.appendingPathComponent("\(job.jobId).json")
            guard let json = job.json else { continue }
            try json.write(to: filePath, atomically: false, encoding: .utf8)
        }
        
        try Zip.zipFiles(paths: [exportPath], zipFilePath: zipPath, password: nil, progress: { value in
            progress(0.3 + (value * 0.7))
        })
        
        if fileManager.fileExists(atPath: exportPath.path) {
            try fileManager.removeItem(at: exportPath)
        }
        
        return zipPath
    }
}

// MARK: Import

extension DataBackup {
    
    func `import`(url: URL, progress: @escaping (DataBackupProgress, DataBackupError?) -> Void) {
        importProgress = DataBackupProgress()
        importError = nil
        
        progressCancellable = Timer.publish(every: 0.1, on: .current, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                
                print("progress: \(self.importProgress.value, places: 5), t: \(Date.timeIntervalSinceReferenceDate)")
                
                if self.importProgress.value == 1 || self.importError != nil {
                    try? self.removeTemporaryFiles()
                    self.progressCancellable?.cancel()
                }
                
                progress(
                    self.importProgress,
                    self.importError
                )
            }
        
        DispatchQueue(label: "import", attributes: .concurrent).async {
            self.importData(url: url)
        }
    }
    
    private func importData(url: URL) {
        let fileManager = FileManager()
        let temporaryPath = fileManager.temporaryDirectory
        let importPath = temporaryPath.appendingPathComponent("import")
        
        do {
            // Create import Directory
            try removeTemporaryFiles()
            try fileManager.createDirectory(at: importPath, withIntermediateDirectories: true, attributes: nil)
            
            // Unzip
            try Zip.unzipFile(url, destination: importPath, overwrite: true, password: nil, progress: { [weak self] value in
                self?.importProgress.unzipProgress = value
            })
            
            guard let unzipPath = try fileManager.contentsOfDirectory(
                    at: importPath,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]).first(where: { url in
                        url.lastPathComponent != "__MACOSX" &&
                            !url.lastPathComponent.hasPrefix(".")
                    }) else {
                self.importError = .invalidDirectoryStructure
                return
            }
            
            // File paths
            let battlePath = unzipPath.appendingPathComponent("battle")
            let battleFilePaths = try fileManager.contentsOfDirectory(
                at: battlePath,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles])
                .filter { $0.pathExtension == "json" }
            
            let salmonRunPath = unzipPath.appendingPathComponent("salmonrun")
            let salmonRunFilePaths = try fileManager.contentsOfDirectory(
                at: salmonRunPath,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles])
                .filter { $0.pathExtension == "json" }
            
            // Load battle and job files
            let fileTotalCount = battleFilePaths.count + salmonRunFilePaths.count
            var loadCount = 0
            
            let records = battleFilePaths
                .map { [weak self] url -> DBRecord? in
                    loadCount += 1
                    self?.importProgress.loadFilesProgress = Double(loadCount) / Double(fileTotalCount)
                    if let data = try? Data(contentsOf: url) {
                        return DBRecord.load(data: data)
                    }
                    return nil
                }
                .filter { $0 != nil && $0?.sp2PrincipalId == AppUserDefaults.shared.sp2PrincipalId }
                .map { $0! }
            
            let jobs = salmonRunFilePaths
                .map { [weak self] url -> DBJob? in
                    loadCount += 1
                    self?.importProgress.loadFilesProgress = Double(loadCount) / Double(fileTotalCount)
                    if let data = try? Data(contentsOf: url) {
                        return DBJob.load(data: data)
                    }
                    return nil
                }
                .filter { $0 != nil && $0?.sp2PrincipalId == AppUserDefaults.shared.sp2PrincipalId }
                .map { $0! }
            
            let allRecordsCount = records.count + jobs.count
            if allRecordsCount > 0 {
                // Progress scale
                let allRecordsScale = 1 - (self.importProgress.unzipProgressScale + self.importProgress.loadFilesProgressScale)
                self.importProgress.importBattlesProgressScale = (Double(records.count) / Double(allRecordsCount)) * allRecordsScale
                self.importProgress.importJobsProgressScale = allRecordsScale - self.importProgress.importBattlesProgressScale
                
                // Write
                AppDatabase.shared.saveBattles(records: records) { [weak self] value, count, error in
                    self?.importProgress.importBattlesProgress = value
                    self?.importProgress.importBattlesCount = count
                    if error != nil {
                        self?.importError = .databaseWriteError
                    }
                }
                
                AppDatabase.shared.saveJobs(jobs: jobs) { [weak self] value, count, error in
                    self?.importProgress.importJobsProgress = value
                    self?.importProgress.importJobsCount = count
                    if error != nil {
                        self?.importError = .databaseWriteError
                    }
                }
            }
            
            self.importProgress.importBattlesProgress = 1
            self.importProgress.importJobsProgress = 1
        } catch is CocoaError {
            self.importError = .invalidDirectoryStructure
        } catch let error {
            os_log("Import Error: \(error.localizedDescription)")
            self.importError = .unknownError
        }
    }
}

extension DataBackup {
    private func removeTemporaryFiles() throws {
        let fileManager = FileManager()
        let temporaryPath = fileManager.temporaryDirectory
        
        let importPath = temporaryPath.appendingPathComponent("import")
        if fileManager.fileExists(atPath: importPath.path) {
            try fileManager.removeItem(at: importPath)
        }
        
        let exportPath = temporaryPath.appendingPathComponent("imink_export")
        if fileManager.fileExists(atPath: exportPath.path) {
            try fileManager.removeItem(at: exportPath)
        }
        
        let zipPath = temporaryPath.appendingPathComponent("imink_export.zip")
        if fileManager.fileExists(atPath: zipPath.path) {
            try fileManager.removeItem(at: zipPath)
        }
    }
}

import UIKit
import SPAlert

extension DataBackup {
    static func `import`(url: URL) {
        DataBackup.shared.import(url: url) { progress, error in
            ProgressHUD.showProgress(CGFloat(progress.value))
            
            if let error = error {
                ProgressHUD.dismiss()
                
                UIAlertController.show(title: "Import Error", message: error.localizedDescription)
            } else if progress.value == 1 {
                ProgressHUD.dismiss()
                SPAlert.present(
                    title: String(format:"Imported %d records".localized, progress.count),
                    preset: progress.count == 0 ?
                        .custom(UIImage(systemName: "exclamationmark.circle.fill")!) :
                        .done
                )
            }
        }
    }
}
