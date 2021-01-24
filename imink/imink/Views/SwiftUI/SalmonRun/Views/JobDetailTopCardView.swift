//
//  JobDetailTopCardView.swift
//  imink
//
//  Created by Jone Wang on 2021/1/21.
//

import SwiftUI
import InkCore

struct JobDetailTopCardView: View {
    let job: Job
    
    var stage: SalmonRunSchedules.Schedule.Stage {
        job.schedule.stage!
    }
    
    var width: CGFloat {
        var screentWidth = UIScreen.main.bounds.size.width
        if screentWidth > 500 {
            screentWidth = 500
        }

        return screentWidth - 64
    }

    var inkOffsetScale: CGFloat {
        var scale = width / 311
        if width >= 436 {
            scale = scale * 0.8
        }
        return scale
    }

    var inkScale: CGFloat {
        width / 311
    }
    
    var body: some View {
        ZStack {
            GrayscaleTextureView(
                texture: .bubble,
                foregroundColor: AppColor.battleDetailStreakForegroundColor,
                backgroundColor: AppColor.listItemBackgroundColor
            )
            .continuousCornerRadius(18)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Image("SalmonRun")
                    
                    Text(job.playTimeText)
                        .sp1Font(size: 12, color: AppColor.spOrange)
                }
                .padding(.bottom, 7)
                
                HStack(spacing: 0) {
                    
                    SalomonRunStageImageView(name: "\(stage.name)_img".localized, imageURL: stage.image)
                        .aspectRatio(1000 / 519, contentMode: .fit)
                        .continuousCornerRadius(6)
                        .frame(width: width * 0.5723)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                        }
                    }
                    .overlay(
                        Image(job.jobResult.isClear ? "JobInkClear" : "JobInkDefeat")
                            .scaleEffect(inkScale, anchor: .topTrailing)
                            .padding(.top, -52 * inkOffsetScale)
                            .padding(.trailing, -32 * inkOffsetScale),
                        alignment: .topTrailing)
                }
                .padding(.bottom, 11.5)
                
                HStack {
                    Text(stage.name.localizedKey)
                        .sp2Font(size: 12, color: .systemGray3)
                    
                    Spacer()
                    
                    HStack(spacing: 10) {
                        HStack(spacing: 3) {
                            Image("GoldenIkura")
                            
                            Text("\(job.myResult.goldenIkuraNum)")
                                .sp2Font(size: 12, color: AppColor.appLabelColor)
                        }
                        
                        HStack(spacing: 3) {
                            Image("Ikura")
                            
                            Text("\(job.myResult.ikuraNum)")
                                .sp2Font(size: 12, color: AppColor.appLabelColor)
                        }
                    }
                }
                .padding(.bottom, 11)
                
                GeometryReader { geo in
                    Path { path in
                        path.move(to: .init(x: 0, y: 0))
                        path.addLine(to: .init(x: geo.size.width, y: 0))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [3.5, 3.5]))
                    .foregroundColor(Color.init(.sRGB, white: 0.4, opacity: 0.36))
                }
                .frame(height: 1)
                .padding(.bottom, 7.5)
                
                HStack {
                    ForEach(job.schedule.weapons!) { weapon in
                        WeaponImageView(id: weapon.id, imageURL: weapon.weapon?.image)
                            .frame(width: 20, height: 20)
                    }
                    
                    Spacer()
                    
                    Text("\("Hazard Level".localized) \(job.dangerRate)%")
                        .sp2Font(size: 12, color: .systemGray)
                }
            }
            .padding([.leading, .trailing], 16)
            .padding(.top, 9)
            .padding(.bottom, 8)
        }
    }
}

extension Job {
    var playTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        return formatter.string(from: playTime)
    }
}

//import SplatNet2API
//
//struct JobTopCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleData = SplatNet2API.jobOverview.sampleData
//        let json = String(data: sampleData, encoding: .utf8)!
//        let jobOverview = json.decode(JobOverview.self)!
//        let job = jobOverview.results[31]
//
//        makeContent(job: job, width: 350, height: 250)
//        makeContent(job: job, width: 375, height: 250)
//        makeContent(job: job, width: 414, height: 250)
//        makeContent(job: job, width: 500, height: 500)
//    }
//
//    static func makeContent(job: Job, width: CGFloat, height: CGFloat) -> some View {
//        ScrollView {
//            JobDetailTopCardView(job: job, width: width - 64)
//                .padding([.leading, .trailing])
//        }
//        .background(AppColor.listBackgroundColor)
//        .previewLayout(.fixed(width: width, height: height))
//    }
//}
