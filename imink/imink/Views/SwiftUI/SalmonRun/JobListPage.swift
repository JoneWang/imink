//
//  JobListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI
import SwiftUIX

struct JobListPage: View {
    @StateObject var viewModel = JobListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundColor(AppColor.listBackgroundColor)
                    .ignoresSafeArea()
                
                CocoaList(viewModel.rows) { job in
                    NavigationLink(destination: JobDetailPage(id: job.id!)) {
                        JobListItemView(job: job)
                            .padding(.top, 8)
                            .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listSeparatorStyle(.none)
                .contentInset(.top, 8)
                .contentInset(.bottom, 16)
                .ignoresSafeArea()
            }
            .navigationBarTitle("Salmon Run", displayMode: .inline)
            .navigationBarHidden(false)
        }
    }
}

struct JobListPage_Previews: PreviewProvider {
    static var previews: some View {
        var rows: [DBJob] = []
        let dbJob = DBJob(
            sp2PrincipalId: "123456789",
            jobId: 222,
            json: nil,
            isClear: true,
            gradePoint: 100,
            gradePointDelta: 20,
            gradeId: "4",
            helpCount: 10,
            deadCount: 9,
            goldenIkuraNum: 22,
            ikuraNum: 33,
            failureWave: nil,
            dangerRate: 152.2)
        
        for _ in 0..<10 {
            rows.append(dbJob)
        }
        
        let page = JobListPage()
        page.viewModel.rows = rows
        
        return page
    }
}
