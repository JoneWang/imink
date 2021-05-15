//
//  MeViewModel.swift
//  imink
//
//  Created by Jone Wang on 2020/10/14.
//

import Foundation
import Combine
import Zip

class MeViewModel: ObservableObject {
    
    @Published var isLogined: Bool = false
    @Published var isLoading: Bool = false
    @Published var records: Records?
    @Published var nicknameAndIcons: NicknameAndIcon?
    
    @Published var exporting: Bool = false
    @Published var packingProgress: Double = 1
    
    private var cancelBag = Set<AnyCancellable>()
    
    init(isLogined: Bool) {
        self.isLogined = isLogined
        
        if (isLogined) {
            self.loadUserInfo()
        }
    }
    
    func loadUserInfo() {
        isLoading = true
        
        Splatoon2API.records
            .request()
            .receive(on: DispatchQueue.main)
            .compactMap { (data: Data) -> Records? in
                // Cache
                AppUserDefaults.shared.splatoon2RecordsData = data
                return data.decode(Records.self)
            }
            .flatMap { [weak self] records -> AnyPublisher<Data, Error> in
                self?.records = records
                return Splatoon2API.nicknameAndIcon(id: records.records.player.principalId)
                    .request()
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
            .compactMap { data -> NicknameAndIcon? in
                // Cache
                AppUserDefaults.shared.splatoon2NicknameAndIconData = data
                return data.decode(NicknameAndIcon.self)
            }
            .sink { [weak self] error in
                self?.isLoading = false
            } receiveValue: { [weak self] nicknameAndIconData in
                self?.isLoading = false
                self?.nicknameAndIcons = nicknameAndIconData
            }
            .store(in: &cancelBag)
            
        loadCacheData()
    }
    
    func loadCacheData() {
        guard let recordsData = AppUserDefaults.shared.splatoon2RecordsData,
              let nicknameAndIconData = AppUserDefaults.shared.splatoon2NicknameAndIconData else {
            return
        }
        
        records = recordsData.decode(Records.self)
        nicknameAndIcons = nicknameAndIconData.decode(NicknameAndIcon.self)
    }
    
    func logOut() {
        AppUserDefaults.shared.sessionToken = nil
    }
}

// Export & Import Data
extension MeViewModel {
    
    func packingData(completed: @escaping (URL?) -> Void) {
        self.exporting = true
        self.packingProgress = 0
        let queue = DispatchQueue(label: "PackingData")
        queue.async {
            let exportPath = try? self.exportData { progress in
                DispatchQueue.main.async {
                    self.packingProgress = progress
                }
            }
            DispatchQueue.main.async {
                self.exporting = false
                self.packingProgress = 1
                completed(exportPath)
            }
        }
    }
    
    private func exportData(progress: @escaping (Double) -> Void) throws -> URL {
        
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
}
