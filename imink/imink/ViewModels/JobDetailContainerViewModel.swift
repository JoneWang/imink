//
//  JobDetailContainerViewModel.swift
//  imink
//
//  Created by Jone Wang on 2022/6/3.
//

import Foundation
import Combine
import os

class JobDetailContainerViewModel: ObservableObject {
    @Published var pages: [JobDetailViewModel] = []
    @Published var currentPageIndex: Int = 0
    @Published var currentJobId: Int
    @Published var currentPageId: Int64? = nil

    private var cancelBag = Set<AnyCancellable>()

    @Published var dbJob: DBJob?

    func update(dbJob: DBJob, initPageId: Int64) {
        currentPageId = initPageId
        currentJobId = dbJob.jobId

        // Load the first data to be displayed.
        Just<Int>.init(0)
            .combineLatest($pages)
            .sink { _, pages in
                let index = pages.firstIndex { $0.id == initPageId } ?? 0

                // Pre-decode the Battle model adjacent to the current index.
                for i in (index - 1) ... (index + 1) {
                    // Data is loaded before entering the page.
                    // So here I use synchronous loading.
                    if pages.indices.contains(i) {
                        pages[i].loadJob(sync: true)
                    }
                }
                self.currentPageIndex = index
            }
            .store(in: &cancelBag)
    }

    init(dbJobs: AnyPublisher<[DBJob], Never>, dbJob: DBJob, initPageId: Int64) {
        currentJobId = dbJob.jobId
        
        update(dbJob: dbJob, initPageId: initPageId)

        dbJobs
            .map { dbJobs -> [JobDetailViewModel] in
                dbJobs.map { dbJob in JobDetailViewModel(dbJob: dbJob) }
            }
            .assign(to: \.pages, on: self)
            .store(in: &cancelBag)

        let currentPageIndexPulisher = $currentPageId
            .removeDuplicates()
            .combineLatest($pages)
            .map { id, pages in
                (Int(pages.firstIndex { $0.id == id } ?? 0), pages)
            }
            .eraseToAnyPublisher()
            .share()
        
        currentPageIndexPulisher
            .map { index, _ in
                index
            }
            .assign(to: \.currentPageIndex, on: self)
            .store(in: &cancelBag)

        currentPageIndexPulisher
            .sink { index, pages in
                // Pre-decode the Battle model adjacent to the current index.
                for i in (index - 1) ... (index + 1) {
                    if pages.indices.contains(i) {
                        pages[i].loadJob()
                    }
                }
            }
            .store(in: &cancelBag)

        currentPageIndexPulisher
            .filter { $1.indices.contains($0) }
            .map { $1[$0].dbJob.jobId }
            .assign(to: \.currentJobId, on: self)
            .store(in: &cancelBag)
    }
    
    func dbJobIndex(with dbJobId: Int64) -> Int? {
        pages.firstIndex { $0.id == dbJobId }
    }
}
