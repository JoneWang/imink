//
//  JobListItemView.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI

struct JobListItemView: View {
    let job: DBJob
    @Binding var selectedId: Int64?
    
    @State private var isSelected: Bool = false
    
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
                    .sp1Font(size: 12, color: AppColor.appLabelColor)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .overlay(
                        Image(pointStatusImageName),
                        alignment: .leading
                    )
                    .frame(width: 13, height:13)
                    .padding([.top, .bottom], 0.5)
                
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
                            .foregroundColor(.systemGray3)
                        
                        Text("\(job.helpCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobDead")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(job.deadCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobGoldenIkura")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(job.goldenIkuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobIkura")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(job.ikuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                }
                .layoutPriority(1)
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
                Text("\("Hazard Level".localized) \(job.dangerRate < 200 ? "\(job.dangerRate)%" : "MAX!!")")
                    .font(.system(size: 10))
                    .foregroundColor(.systemGray2)
                
                Spacer()
            }
        }
        .padding(.top, 7.5)
        .padding(.bottom, 7)
        .padding([.leading, .trailing], 8)
        .background(isSelected ? .systemGray5 : AppColor.listItemBackgroundColor)
        .frame(height: 79)
        .continuousCornerRadius(10)
        .onChange(of: selectedId) { value in
            withAnimation {
                self.isSelected = selectedId == job.id
            }
        }
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
            ikuraNum: 334,
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
        
        StatefulPreviewWrapper(0) { selectedId in
            JobListItemView(job: dbJob, selectedId: selectedId)
                .padding(.top, 8)
                .padding([.leading, .trailing])
                .background(AppColor.listBackgroundColor)
                .frame(width: 300)
                .previewLayout(.sizeThatFits)
        }
        
        StatefulPreviewWrapper(0) { selectedId in
            JobListItemView(job: dbJob, selectedId: selectedId)
                .padding(.top, 8)
                .padding([.leading, .trailing])
                .background(AppColor.listBackgroundColor)
                .previewLayout(.sizeThatFits)
                .colorScheme(.dark)
        }
    }
}
