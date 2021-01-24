//
//  JobListItemView.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI

struct JobListItemView: View {
    let job: DBJob
    
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
            let resultColor = job.isClear ? AppColor.waveClearColor : AppColor.waveDefeatColor
            
            HStack(spacing: 6) {
                Text("\("grade_\(job.gradeId)".localized) \(job.gradePoint)")
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
                Text(job.isClear ? "Clear!" : "Defeat_job")
                    .sp1Font(size: 14, color: resultColor)
                
                Spacer()
                
                HStack {
                    HStack(spacing: 3) {
                        Image("JobHelp")
                        Text("\(job.helpCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobDead")
                        Text("\(job.deadCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobGoldenIkura")
                        Text("\(job.goldenIkuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobIkura")
                        Text("\(job.ikuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                }
            }
            .padding(.bottom, 7)
            
            HStack {
                ForEach(0..<3) { index in
                    Rectangle()
                        .foregroundColor((job.failureWave ?? 3 >= index + 1) ? resultColor : .systemGray3)
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
        
        JobListItemView(job: dbJob)
            .padding(.top, 8)
            .padding([.leading, .trailing])
            .background(AppColor.listBackgroundColor)
            .previewLayout(.sizeThatFits)
        
        JobListItemView(job: dbJob)
            .padding(.top, 8)
            .padding([.leading, .trailing])
            .background(AppColor.listBackgroundColor)
            .previewLayout(.sizeThatFits)
            .colorScheme(.dark)
    }
}
