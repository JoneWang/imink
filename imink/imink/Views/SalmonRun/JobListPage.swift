//
//  JobListPage.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI

struct JobListPage: View {
    @EnvironmentObject var mainViewModel: MainViewModel
            
    @StateObject var viewModel = JobListViewModel()
    
    @State var selectedJob: DBJob?
    
    var body: some View {
        if viewModel.isLogined {
            content
                .navigationViewStyle(.automatic)
        } else {
            content
                .navigationViewStyle(.stack)
        }
    }
    
    var content: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.rows, id: \.id) { row in
                        if let shiftCard = row.shiftCard {
                            JobShiftCardView(shiftCard: shiftCard)
                                .rotationEffect(.degrees(-1))
                                .clipped(antialiased: true)
                                .padding([.leading, .trailing], 26)
                                .padding(.top, 15)
                                // FIXME:
                                .padding(.bottom, 0.1)
                        } else if let job = row.job {
                            JobListItemView(job: job, selectedId: $viewModel.selectedId)
                                .padding([.leading, .trailing])
                                .onTapGesture {
                                    self.viewModel.selectedId = job.id
                                }
                                .background(
                                    NavigationLink(
                                        destination: JobDetailPage(id: job.id!),
                                        tag: job.id!,
                                        selection: $viewModel.selectedId
                                    ) { EmptyView() }
                                    .buttonStyle(PlainButtonStyle())
                                )
                        }
                    }
                }
                .padding(.bottom, 16)
            }
            .fixSafeareaBackground()
            .modifier(LoginViewModifier(isLogined: viewModel.isLogined, iconName: "TabBarSalmonRun"))
            .navigationBarTitle("Salmon Run", displayMode: .inline)
            .navigationBarHidden(false)
        }
        .onReceive(mainViewModel.$isLogined) { isLogined in
            viewModel.updateLoginStatus(isLogined: isLogined)
        }
    }
}

struct JobListPage_Previews: PreviewProvider {
    static var previews: some View {
        var rows: [JobListRowModel] = []
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
            dangerRate: 152.2,
            scheduleStartTime: Date(),
            scheduleEndTime: Date(),
            scheduleStageName: "Stage Name",
            scheduleWeapon1Id: "0",
            scheduleWeapon1Image: "",
            scheduleWeapon2Id: "0",
            scheduleWeapon2Image: "",
            scheduleWeapon3Id: "0",
            scheduleWeapon3Image: "",
            scheduleWeapon4Id: "0",
            scheduleWeapon4Image: ""
            )
        
        for _ in 0..<10 {
            rows.append(JobListRowModel(type: .job, job: dbJob))
        }
        
        let viewModel = JobListViewModel()
        let page = JobListPage(viewModel: viewModel)
        page.viewModel.rows = rows
        
        return page
    }
}
