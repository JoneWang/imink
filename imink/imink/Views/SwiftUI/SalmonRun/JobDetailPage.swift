//
//  JobDetailPage.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI
import InkCore

struct JobDetailPage: View {
    let job: Job
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                JobDetailTopCardView(job: job)
                
                HStack(alignment: .top, spacing: 16) {
                    ForEach(0..<3) { index in
                        if index < job.waveDetails.count {
                            JobDetailWaveView(waveIndex: index, job: job)
                                .rotationEffect(.degrees(2))
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
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 20)
        }
        .background(AppColor.listBackgroundColor)
    }
}

extension Job {
    var results: [PlayerResult] {
        [myResult] + (otherResults ?? [])
    }
}

import SplatNet2API

struct JobDetailPage_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = SplatNet2API.jobOverview.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let jobOverview = json.decode(JobOverview.self)!
        
        JobDetailPage(job: jobOverview.results[3])
        JobDetailPage(job: jobOverview.results[0])
            .previewDevice("iPhone 12 Pro Max")
        JobDetailPage(job: jobOverview.results[0])
            .previewDevice("iPad Pro (9.7-inch)")
    }
}
