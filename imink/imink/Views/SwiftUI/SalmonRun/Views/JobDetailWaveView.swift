//
//  JobDetailWaveView.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct JobDetailWaveView: View {
    let waveIndex: Int
    let job: Job
    
    var waveDetail: Job.WaveDetail {
        job.waveDetails[waveIndex]
    }
    
    var playerResults: [Job.PlayerResult] {
        job.results
    }
    
    var waveHeight: CGFloat {
        switch waveDetail.waterLevel.key {
        case .high:
            return 77
        case .normal:
            return 49
        case .low:
            return 16
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Spacer()
                    
                    WaveShape()
                        .fill(LinearGradient(
                                gradient: Gradient(colors: [AppColor.waveGradientStartColor, AppColor.listItemBackgroundColor]),
                                startPoint: .top,
                                endPoint: .bottom))
                        .frame(height: waveHeight)
                }
                
                VStack {
                    VStack(spacing: 9) {
                        Text("\(String(format: "Wave %d".localized, waveIndex + 1))")
                            .sp2Font(color: .systemGray)
                            .padding(.bottom, -1)
                        
                        Text("\(waveDetail.goldenIkuraNum)/\(waveDetail.quotaNum)")
                            .sp2Font(size: 14, color: AppColor.appLabelColor)
                        
                        Text(waveDetail.waterLevel.key.rawValue.localizedKey)
                            .sp2Font(size: 10, color: .systemGray)
                        
                        Text(waveDetail.eventType.key.localizedKey)
                            .sp2Font(size: 10, color: .systemGray)
                    }
                    .padding(.top, 14)
                    
                    Spacer()
                }
            }
            .frame(width: 100, height: 100)
            .background(AppColor.listItemBackgroundColor)
            .continuousCornerRadius(10)
            .overlay(
                Image("Hook")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 8)
                    .foregroundColor(AppColor.listBackgroundColor),
                alignment: .top
            )
            .overlay(
                Image((job.jobResult.failureWave ?? 9) <= (waveIndex + 1) ? "JobWaveDefeat" : "JobWaveClear")
                    .position(x: 86, y: 11)
            )
            
            let allSpecialCount = playerResults.reduce(0) { $0 + $1.specialCounts[waveIndex] }
            let allSpecials = playerResults.reduce(Array<Weapon.Equipment>()) { specials, result in
                var sps: [Weapon.Equipment] = []
                for _ in 0..<result.specialCounts[waveIndex] {
                    sps.append(result.special)
                }
                return specials + sps
            }
            
            ForEach(0..<(allSpecialCount + 3) / 4) { (i: Int) in
                HStack(spacing: 6) {
                    ForEach((i * 4)..<((i + 1) * 4)) { (j: Int) in
                        if j < allSpecials.count {
                            let special = allSpecials[j]
                            Rectangle()
                                .overlay(
                                    WebImage(url: special.imageA)
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                )
                                .foregroundColor(AppColor.salmonRunSpecialBackgroundColor)
                                .frame(width: 14, height: 14)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
    }
}

import SplatNet2API

struct JobDetailWavesView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = SplatNet2API.jobOverview.sampleData
        let json = String(data: sampleData, encoding: .utf8)!
        let jobOverview = json.decode(JobOverview.self)!
        let job = jobOverview.results[3]
        
        JobDetailWaveView(waveIndex: 2, job: job)
            .previewLayout(.sizeThatFits)
        
        JobDetailWaveView(waveIndex: 2, job: job)
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
