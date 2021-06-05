//
//  JobDetailMemberView.swift
//  imink
//
//  Created by Jone Wang on 2021/1/22.
//

import SwiftUI
import InkCore

struct JobDetailMemberView: View {
    let playerResult: Job.PlayerResult
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(playerResult.name)
                    .sp2Font(size: 13, color: AppColor.appLabelColor)
                
                HStack {
                    HStack(spacing: 3) {
                        Image("JobHelp")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(playerResult.helpCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobDead")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(playerResult.deadCount)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobGoldenIkura")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(playerResult.goldenIkuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobIkura")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(playerResult.ikuraNum)")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                    
                    HStack(spacing: 3) {
                        Image("JobKillBoss")
                            .foregroundColor(.systemGray3)
                        
                        Text("\(playerResult.bossKillCounts.values.reduce(0) { $0 + $1.count })")
                            .sp2Font(size: 10, color: AppColor.appLabelColor)
                    }
                }
            }
            .padding(.top, 5)
            .padding(.bottom, 4)
            
            Spacer()
            
            HStack {
                ForEach(playerResult.weaponList, id: \.id) { weapon in
                    Rectangle()
                        .overlay(
                            ImageView.weapon(id: weapon.id, imageURL: weapon.weapon?.image)
                                .frame(width: 22, height: 22)
                                .padding(.leading, 2),
                            alignment: .leading
                        )
                        .frame(width: 22, height: 22)
                        .clipShape(Capsule())
                        .foregroundColor(.systemGray5)
                }
                
                Rectangle()
                    .overlay(
                        ImageView.special(id: playerResult.special.id)
                            .frame(width: 14, height: 14)
                    )
                    .foregroundColor(AppColor.salmonRunSpecialBackgroundColor)
                    .frame(width: 22, height: 22)
                    .clipShape(Capsule())
            }
        }
        .padding(.leading, 19)
        .padding(.trailing, 10)
        .frame(height: 38)
        .background(AppColor.listItemBackgroundColor)
        .clipShape(Capsule())
    }
}

import SplatNet2API

struct JobDetailMemberView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = SplatNet2API.jobOverview.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let jobOverview = json.decode(JobOverview.self)!
        let job = jobOverview.results[4]
        
        JobDetailMemberView(playerResult: job.results[0])
            .previewLayout(.sizeThatFits)
    }
}
