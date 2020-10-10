//
//  HomePage.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import SwiftUI

struct HomePage: View {
    
    @StateObject private var homeViewModel = HomeViewModel()
    
    @State private var scheduleType = 0
    @State private var chartType = 0
    @State private var vdChartData = [Bool]()
    @State private var vdChartViewHeight: CGFloat = 0
    @State private var todayVictoryCount: Int = 0
    @State private var todayDefeatCount: Int = 0
    @State private var todayKillCount: Int = 0
    @State private var todayDeathCount: Int = 0
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack {
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack(alignment: .lastTextBaseline) {
                            
                            Text("# Today")
                                .sp2Font(size: 20, color: Color.primary)
                            
                            Text("(3:00 reset)")
                                .sp2Font(color: Color.secondary)
                            
                        }
                        
                        HStack {
                            
                            VStack {
                                HStack {
                                    
                                    PieView(value1: Double(todayVictoryCount), value2: Double(todayDefeatCount), color1: AppColor.spPink, color2: AppColor.spLightGreen)
                                        .opacity(0.9)
                                        .frame(width: 25, height: 25)
                                    
                                    Text("Victory:")
                                        .sp2Font(size: 16, color: Color.primary)
                                    
                                    Text("\((Double(todayVictoryCount) &/ Double(todayVictoryCount + todayDefeatCount)) * 100)%")
                                        .sp2Font(size: 16, color: Color.secondary)
                                    
                                }
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
                                        
                                        Text("VICTORY")
                                            .sp2Font(size: 10, color: Color.secondary)
                                        
                                        Text("\(todayVictoryCount)")
                                            .sp1Font(size: 24, color: AppColor.spPink)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
                                        
                                        Text("DEFEAT")
                                            .sp2Font(size: 10, color: Color.secondary)
                                        
                                        Text("\(todayDefeatCount)")
                                            .sp1Font(size: 24, color: AppColor.spLightGreen)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                }
                            }
                            .padding()
                            .background(Color.primary.opacity(0.1))
                            .cornerRadius(10)
                            
                            VStack {
                                HStack {
                                    
                                    PieView(value1: Double(todayKillCount), value2: Double(todayDeathCount), color1: .red, color2: Color.gray.opacity(0.5))
                                        .opacity(0.9)
                                        .frame(width: 25, height: 25)
                                    
                                    Text("K/D:")
                                        .sp2Font(size: 16, color: Color.primary)
                                    
                                    Text("\(Double(todayKillCount) &/ Double(todayDeathCount), places: 1)")
                                        .sp2Font(size: 16, color: Color.secondary)
                                    
                                }
                                
                                HStack {
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
                                        
                                        Text("KILL")
                                            .sp2Font(size: 10, color: Color.secondary)
                                        
                                        Text("\(todayKillCount)")
                                            .sp1Font(size: 24, color: .red)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
                                        
                                        Text("DEATH")
                                            .sp2Font(size: 10, color: Color.secondary)
                                        
                                        Text("\(todayDeathCount)")
                                            .sp1Font(size: 24, color: Color.gray.opacity(0.5))
                                        
                                    }
                                    
                                    Spacer()
                                    
                                }
                            }
                            .padding()
                            .background(Color.primary.opacity(0.1))
                            .cornerRadius(10)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack(alignment: .lastTextBaseline) {
                            
                            Text("# Results")
                                .sp2Font(size: 20, color: Color.primary)
                            
                            Text("(Last 500)")
                                .sp2Font(color: Color.secondary)
                            
                        }
                        
                        GeometryReader { geo in
                            HStack {
                                Spacer()
                                
                                Text("Last 50")
                                    .sp2Font(size: 16, color: Color.secondary)
                                    .minimumScaleFactor(0.5)
                                    .frame(width: geo.size.width / 10 - 2)
                            }
                        }
                        .frame(height: 20)
                        
                        VDGridView(data: vdChartData, height: $vdChartViewHeight)
                            .frame(height: vdChartViewHeight)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("# Schedule")
                            .sp2Font(size: 20, color: Color.primary)
                        
                        VStack {
                            Picker(selection: $scheduleType, label: Text("Picker"), content: {
                                Text("Battle").tag(0)
                                Text("Salmon Run").tag(1)
                            })
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 230)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                        
                        if scheduleType == 0 {
                            if let schedules = homeViewModel.schedules {
                                ScheduleView(
                                    regularSchedules: schedules.regular,
                                    gachiSchedules: schedules.gachi,
                                    leagueSchedules: schedules.league
                                )
                                .padding(.top)
                            } else {
                                makeLoadingView()
                            }
                        } else {
                            if let salmonRunSchedules = homeViewModel.salmonRunSchedules {
                                SalmonRunScheduleView(
                                    schedules: salmonRunSchedules
                                )
                                .padding(.top)
                            } else {
                                makeLoadingView()
                            }
                        }
                        
                    }
                    .padding()
                    .animation(.default)
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(trailing: makeNavigationBarItems())
            .navigationBarHidden(false)
            .onReceive(homeViewModel.$recordTotalCount) { _ in
                vdChartData = homeViewModel.vdWithLast500
                (todayVictoryCount, todayDefeatCount) = homeViewModel.todayVictoryAndDefeatCount
                (todayKillCount, todayDeathCount) = homeViewModel.todayKillAndDeathCount
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func makeLoadingView() -> some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .padding()
        .background(Color.primary.opacity(0.1))
        .cornerRadius(10)
        .padding(.top)
    }
    
    func makeNavigationBarItems() -> some View {
        HStack {
            if homeViewModel.isLoading {
                ProgressView()
            } else {
                Button(action: {
                    homeViewModel.updateSchedules()
                }) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                }
            }
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
