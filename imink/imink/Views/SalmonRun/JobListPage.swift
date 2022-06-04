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
    
    @State private var rows: [JobListRowModel] = []
    @State private var jobDetailPresented: Bool = false
    @State var selectedRow: JobListRowModel?
    
    @State private var currentDBJobIdInDetail: Int64?

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
            ZStack {
                ScrollViewReader { proxy in
                    NavigationLink(
                        destination: detailPage,
                        isActive: $jobDetailPresented
                    ) { EmptyView() }
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(rows, id: \.id) { row in
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
                                            viewModel.selectedId = row.dbId
                                            selectedRow = row
                                            jobDetailPresented = true
                                        }
                                        .id(row.dbId)
                                }
                            }
                        }
                        .padding(.bottom, 16)
                        .onChange(of: currentDBJobIdInDetail) { recordId in
                            withAnimation {
                                proxy.scrollTo(recordId, anchor: .center)
                            }
                        }
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
            .onAppear {
                self.rows = viewModel.rows
            }
            .onChange(of: viewModel.rows) { rows in
                withAnimation {
                    self.rows = rows
                }
            }
            .onChange(of: jobDetailPresented) { newValue in
                if !newValue {
                    viewModel.selectedId = nil
                }
            }
        }
    }
    
    var detailPage: some View {
        Group {
            if let row = selectedRow {
                JobDetailPageContainer(
                    viewModel: JobDetailContainerViewModel(
                        dbJobs: viewModel.$databaseDBJobs.eraseToAnyPublisher(),
                        dbJob: row.job!,
                        initPageId: row.dbId),
                    showPage: { pageId in
                        if jobDetailPresented {
                            currentDBJobIdInDetail = pageId
                            viewModel.selectedId = pageId
                        }
                    },
                    initPageId: row.dbId,
                    isPresented: $jobDetailPresented,
                    selectedRow: row
                )
            } else {
                EmptyView()
            }
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
