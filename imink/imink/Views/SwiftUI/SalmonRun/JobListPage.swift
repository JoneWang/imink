//
//  JobListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI
import SwiftUIX

struct JobListPage: View {
    @StateObject private var viewModel = JobListViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundColor(AppColor.listBackgroundColor)
                    .ignoresSafeArea()
                
                CocoaList(viewModel.rows) { job in
                    NavigationLink(destination: JobDetailPage()) {
                        ZStack {
                            if viewModel.rows.first == job {
                                JobListItemView(job: job.job)
                                    .padding(.top, 8)
                            } else if viewModel.rows.last == job {
                                JobListItemView(job: job.job)
                                    .padding(.bottom, 16)
                            } else {
                                JobListItemView(job: job.job)
                            }
                        }
                        .padding(.top, 8)
                        .padding([.leading, .trailing])
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .listSeparatorStyle(.none)
                .ignoresSafeArea()
            }
            .navigationBarTitle("Salmon Run", displayMode: .inline)
            .navigationBarHidden(false)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct JobListPage_Previews: PreviewProvider {
    static var previews: some View {
        JobListPage()
    }
}
