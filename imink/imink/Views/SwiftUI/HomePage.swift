//
//  HomePage.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import SwiftUI

struct HomePage: View {
    
    @StateObject var homeViewModel = HomeViewModel()
    
    @State var totalKillCount = 0
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    
                    Text("imink")
                        .sp2Font(size: 50, color: .primary)
                    
                    Spacer()
                }
                .padding()
                
                HStack {
                    GeometryReader { geo in
                        Rectangle()
                            .foregroundColor(AppColor.spPink)
                            .frame(width: geo.size.width * CGFloat((Double(homeViewModel.synchronizedCount) &/ Double(homeViewModel.syncTotalCount))))
                    }
                }
                .frame(height: 10)
                .clipShape(Capsule())
                .animation(.linear)
                .padding(.horizontal)
                
                HStack(alignment: .top, spacing: 20) {
                    
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 150))],
                        alignment: .center
                    ) {
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(AppColor.spGreen)
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Record Count:")
                                        .sp2Font(size: 20)
                                        .minimumScaleFactor(0.5)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                Text("\(homeViewModel.recordTotalCount)")
                                    .sp1Font(size: 35)
                                    .minimumScaleFactor(0.3)
                                
                                Spacer()
                            }
                            .padding()
                            
                            Spacer()
                        }
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                        
                        ZStack {
                            Rectangle()
                                .foregroundColor(AppColor.spRed)
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("Total Kill:")
                                        .sp2Font(size: 20)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                Text("\(totalKillCount)")
                                    .sp1Font(size: 35)
                                    .minimumScaleFactor(0.3)
                                
                                Spacer()
                            }
                            .padding()
                            
                            Spacer()
                        }
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                        
                    }
                    
                }
                .padding(.top, 30)
                
                ScheduleView(
                    regularSchedules: homeViewModel.schedules?.regular ?? [],
                    gachiSchedules: homeViewModel.schedules?.gachi ?? [],
                    leagueSchedules: homeViewModel.schedules?.league ?? []
                )
                
                Spacer()
            }
        }
        .onAppear {
            totalKillCount = homeViewModel.totalKillCount
        }
    }
}

struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage()
            .previewLayout(.sizeThatFits)
            .frame(width: 1024, height: 768)
        
        HomePage()
            .previewLayout(.sizeThatFits)
            .frame(width: 400, height: 768)
    }
}
