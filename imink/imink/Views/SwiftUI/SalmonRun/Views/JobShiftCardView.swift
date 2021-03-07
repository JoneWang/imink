//
//  JobShiftCardView.swift
//  imink
//
//  Created by Jone Wang on 2021/3/6.
//

import SwiftUI
import InkCore

struct JobShiftCardView: View {
    let shiftCard: JobListRowModel.ShiftCard
    
    var body: some View {
        VStack(spacing: -1) {
            HStack {
                VStack(alignment: .leading) {
                    Text(shiftCard.timeIntervalText)
                        .sp2Font(color: AppColor.appLabelColor)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            HStack(spacing: 3) {
                                Image("JobShiftCardClear_img".localized)
                                Text("\(shiftCard.avgClearCount, places: 1)")
                                    .sp2Font(size: 10, color: AppColor.appLabelColor)
                            }
                            .frame(width: 36, alignment: .leading)
                            
                            HStack(spacing: 3) {
                                Image("JobShiftCardGoldenIkura")
                                Text("\(shiftCard.avgGoldenIkuraCount, places: 1)")
                                    .sp2Font(size: 10, color: AppColor.appLabelColor)
                            }
                        }
                        
                        HStack {
                            HStack(spacing: 3) {
                                Image("JobShiftCardHelp")
                                Text("\(shiftCard.avgHelpCount, places: 1)")
                                    .sp2Font(size: 10, color: AppColor.appLabelColor)
                            }
                            .frame(width: 36, alignment: .leading)
                            
                            HStack(spacing: 3) {
                                Image("JobShiftCardDead")
                                Text("\(shiftCard.avgDeadCount, places: 1)")
                                    .sp2Font(size: 10, color: AppColor.appLabelColor)
                            }
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 10) {
                    Text(shiftCard.scheduleStageName.localizedKey)
                        .sp2Font(size: 10, color: .systemGray2)
                    
                    HStack {
                        ForEach(0..<4) { i in
                            let weapon = shiftCard.weapons[i]
                            WeaponImageView(id: weapon.0, imageURL: weapon.1)
                                .frame(width: 20, height: 20)
                        }
                    }
                    .padding([.leading, .trailing], 10)
                    .padding([.top, .bottom], 6)
                    .background(Color(.sRGB, white: 151 / 255.0, opacity: 0.1))
                    .continuousCornerRadius(7)
                }
                .padding(.bottom, 2)
            }
            .padding([.leading, .top, .trailing], 13)
            .padding(.bottom, 11)
            .frame(height: 79)
            .background(
                GrayscaleTextureView(
                    texture: .bubble,
                    foregroundColor: AppColor.battleDetailStreakForegroundColor,
                    backgroundColor: AppColor.listItemBackgroundColor
                )
                .frame(height: 100),
                alignment: .topLeading
            )
            .continuousCornerRadius(10)
            
            VStack { }
                .frame(maxWidth: .infinity, minHeight: 19, maxHeight: 19)
                .overlay(
                    GrayscaleTextureView(
                        texture: .bubble,
                        foregroundColor: AppColor.battleDetailStreakForegroundColor,
                        backgroundColor: AppColor.listItemBackgroundColor
                    )
                    .frame(height: 100)
                    .offset(y: -78)
                    .mask(
                        VStack {
                            HStack {
                                Spacer()
                                Image("JobShiftCardTail")
                                    .resizable()
                                    .frame(width: 33, height: 19)
                            }
                            Spacer()
                        }
                        .padding(.trailing, 24)
                    ),
                    alignment: .topLeading
                )
        }
        .frame(height: 97)
        .animation(.easeOut)
    }
}

extension JobListRowModel.ShiftCard {
    
    var timeIntervalText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return "\(formatter.string(from: scheduleStartTime)) - \(formatter.string(from: scheduleEndTime))"
    }
    
    var avgClearCount: Double {
        Double(totalClearCount) / Double(gameCount)
    }
    
    var avgHelpCount: Double {
        Double(totalHelpCount) / Double(gameCount)
    }
    
    var avgGoldenIkuraCount: Double {
        Double(totalGoldenIkuraCount) / Double(gameCount)
    }
    
    var avgDeadCount: Double {
        Double(totalDeadCount) / Double(gameCount)
    }
    
    var weapons: [(String, URL)] {
        [
            (scheduleWeapon1Id, Splatoon2API.host.appendingPathComponent(scheduleWeapon1Image)),
            (scheduleWeapon2Id, Splatoon2API.host.appendingPathComponent(scheduleWeapon2Image)),
            (scheduleWeapon3Id, Splatoon2API.host.appendingPathComponent(scheduleWeapon3Image)),
            (scheduleWeapon4Id, Splatoon2API.host.appendingPathComponent(scheduleWeapon4Image)),
        ]
    }
    
}

struct JobShiftCardView_Previews: PreviewProvider {
    static var previews: some View {
        JobShiftCardView(
            shiftCard: JobListRowModel.ShiftCard(
                scheduleStartTime: Date(),
                scheduleEndTime: Date(),
                scheduleStageName: "Marooner's Bay",
                scheduleWeapon1Id: "0",
                scheduleWeapon1Image: "",
                scheduleWeapon2Id: "0",
                scheduleWeapon2Image: "",
                scheduleWeapon3Id: "0",
                scheduleWeapon3Image: "",
                scheduleWeapon4Id: "0",
                scheduleWeapon4Image: "",
                totalClearCount: 44,
                totalHelpCount: 34,
                totalGoldenIkuraCount: 180,
                totalDeadCount: 14,
                gameCount: 7
            )
        )
        .preferredColorScheme(.dark)
        .rotationEffect(.degrees(-1))
        .padding([.top, .bottom], 8)
        .padding([.leading, .trailing])
        .background(AppColor.listBackgroundColor)
        .previewLayout(.sizeThatFits)
    }
}
