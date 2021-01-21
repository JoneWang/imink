//
//  JobListItemView.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI

struct JobListItemView: View {
    let job: Job
    
    var pointStatusImageName: String {
        if job.gradePointDelta > 0 {
            return "JobUp"
        } else if job.gradePointDelta < 0 {
            return "JobFall"
        } else {
            return "JobStand"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            let resultColor = job.jobResult.isClear ? AppColor.waveClearColor : AppColor.waveDefeatColor
            
            HStack(spacing: 6) {
                Text("\("grade_\(job.grade.id)".localized) \(job.gradePoint)")
                    .sp1Font(size: 14, color: AppColor.appLabelColor)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay(
                        Image(pointStatusImageName),
                        alignment: .leading
                    )
                    .frame(width: 13, height:13)
                
                Spacer()
            }
            .padding(.bottom, 6.5)
            
            HStack {
                Text(job.jobResult.isClear ? "Clear!" : "Defeat_job")
                    .sp1Font(size: 14, color: resultColor)
                
                Spacer()
                
                HStack {
                    HStack(spacing: 3) {
                        Image("JobHelp")
                        Text("\(job.myResult.helpCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobDead")
                        Text("\(job.myResult.deadCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobGoldenIkura")
                        Text("\(job.myResult.goldenIkuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobIkura")
                        Text("\(job.myResult.ikuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                }
            }
            .padding(.bottom, 7)
            
            HStack {
                ForEach(0..<3) { index in
                    Rectangle()
                        .foregroundColor((job.jobResult.failureWave ?? 3 >= index + 1) ? resultColor : .systemGray3)
                        .frame(height: 5)
                        .clipShape(Capsule())
                }
            }
            .padding(.bottom, 6)
            
            HStack {
                Text("\("Hazard Level".localized) \(job.dangerRate)%")
                    .font(.system(size: 12))
                    .foregroundColor(.systemGray2)
                
                Spacer()
            }
        }
        .padding(.top, 7.5)
        .padding(.bottom, 7)
        .padding([.leading, .trailing], 8)
        .background(AppColor.listItemBackgroundColor)
        .frame(height: 79)
        .continuousCornerRadius(10)
    }
}

import SplatNet2API

struct JobListItemView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = SplatNet2API.jobOverview.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let jobOverview = json.decode(JobOverview.self)!
        
        VStack(spacing: 0) {
            JobListItemView(job: jobOverview.results[0])
                .padding(.top, 8)
                .padding([.leading, .trailing])
            
            JobListItemView(job: jobOverview.results[30])
                .padding(.top, 8)
                .padding([.leading, .trailing])
        }
        .frame(width: 375, height: 300)
        .background(AppColor.listBackgroundColor)
        .previewLayout(.sizeThatFits)
    }
}
