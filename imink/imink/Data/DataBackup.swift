//
//  DataBackup.swift
//  imink
//
//  Created by Jone Wang on 2021/6/3.
//

import Foundation
import Zip

struct DataBackup {
    
    static func export(progress: @escaping (Bool, Double, URL?) -> Void) {
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
    
    private static func packingData(progress: @escaping (Double) -> Void) throws -> URL {
        
        let fileManager = FileManager()
        let temporaryPath = fileManager.temporaryDirectory
        
        let exportPath = temporaryPath.appendingPathComponent("imink_export")
        if fileManager.fileExists(atPath: exportPath.path) {
            try fileManager.removeItem(at: exportPath)
        }
        
        let zipPath = temporaryPath.appendingPathComponent("imink_export.zip")
        if fileManager.fileExists(atPath: zipPath.path) {
            try fileManager.removeItem(at: zipPath)
        }
        
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
        
        return zipPath
    }
    
    static func `import`(url: URL) {
        let fileManager = FileManager()
        let temporaryPath = fileManager.temporaryDirectory
        let importPath = temporaryPath.appendingPathComponent("import")
        
        if fileManager.fileExists(atPath: importPath.path) {
            try! fileManager.removeItem(at: importPath)
        }
        try! fileManager.createDirectory(at: importPath, withIntermediateDirectories: true, attributes: nil)
        
        try! Zip.unzipFile(url, destination: importPath, overwrite: true, password: nil)
        
        guard let unzipPath = try! fileManager.contentsOfDirectory(
                at: importPath,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]).first(where: { url in
                    url.lastPathComponent != "__MACOSX" &&
                        !url.lastPathComponent.hasPrefix(".")
                }) else {
            return
        }
        
        let battlePath = unzipPath.appendingPathComponent("battle")
        let battleDatas = try! fileManager.contentsOfDirectory(
            at: battlePath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles])
            .filter { $0.pathExtension == "json" }
            .map { try? Data(contentsOf: $0) }
            .filter { $0 != nil }
            .map { $0! }
        AppDatabase.shared.saveBattles(datas: battleDatas)
        
        
        let salmonRunPath = unzipPath.appendingPathComponent("salmonrun")
        let salmonRunDatas = try! fileManager.contentsOfDirectory(
            at: salmonRunPath,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles])
            .filter { $0.pathExtension == "json" }
            .map { try? Data(contentsOf: $0) }
            .filter { $0 != nil }
            .map { $0! }
        AppDatabase.shared.saveJobs(datas: salmonRunDatas)
    }
}
