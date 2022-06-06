//
//  JobDetailPage.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI
import InkCore

struct JobDetailPage: View {
    
    @StateObject var viewModel: JobDetailViewModel

    var topSafearea: CGFloat = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0

    var body: some View {
        ScrollView {
            HStack {
                Spacer()
                
                if let job = viewModel.job {
                    VStack(spacing: 16) {
                        JobDetailTopCardView(job: job)
                        
                        HStack(alignment: .top, spacing: 16) {
                            ForEach(0..<3) { index in
                                if index < job.waveDetails.count {
                                    JobDetailWaveView(waveIndex: index, job: job)
                                        .rotationEffect(.degrees(-2))
                                }
                            }
                        }
                        
                        VStack(spacing: 6) {
                            ForEach(job.results, id: \.pid) { playerResult in
                                if playerResult.pid == job.myResult.pid {
                                    JobDetailMemberView(playerResult: playerResult)
                                        .overlay(
                                            Image("MemberArrow")
                                                .foregroundColor(AppColor.memberArrowColor)
                                                .position(x: 1, y: 18.5)
                                        )
                                } else {
                                    JobDetailMemberView(playerResult: playerResult)
                                }
                            }
                        }
                    }
                    .padding([.top, .bottom], 20)
                    .frame(maxWidth: 500)
                }
                
                Spacer()
            }
            .padding(.horizontal, 8)
            // FIXME: When two ScrollViews are nested. The inner one ScrollView has no safa area.
            .padding(.top, topSafearea + 44)
        }
        .frame(maxWidth: .infinity)
        .fixSafeareaBackground()
    }
}

extension Job {
    var results: [PlayerResult] {
        [myResult] + (otherResults ?? [])
    }
}

//import SplatNet2API
//
//struct JobDetailPage_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleData = SplatNet2API.jobOverview.sampleData
//        let json = String(data: sampleData, encoding: .utf8)!
//        let jobOverview = json.decode(JobOverview.self)!
//
//        let page = JobDetailPage(id: 0)
//        page.viewModel.job = jobOverview.results[0]
//
//        return VStack {
//            page
//        }
//    }
//}
