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
    @State private var todayAssistCount: Int = 0
    @State private var todayDeathCount: Int = 0
    
    @AppStorage("showKDInHome")
    var showKD: Bool = false
    
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
                                    
                                    PieView(values: [Double(todayVictoryCount), Double(todayDefeatCount)], colors: [AppColor.spPink, AppColor.spLightGreen])
                                        .opacity(0.9)
                                        .frame(width: 25, height: 25)
                                    
                                    Text("Victory:")
                                        .sp2Font(size: 16, color: Color.primary)
                                        .minimumScaleFactor(0.5)
                                    
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
                                            .minimumScaleFactor(0.5)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
                                        
                                        Text("DEFEAT")
                                            .sp2Font(size: 10, color: Color.secondary)
                                        
                                        Text("\(todayDefeatCount)")
                                            .sp1Font(size: 24, color: AppColor.spLightGreen)
                                            .minimumScaleFactor(0.5)
                                        
                                    }
                                    
                                    Spacer()
                                    
                                }
                            }
                            .padding()
                            .background(AppColor.listItemBackgroundColor)
                            .cornerRadius(10)
                            
                            ZStack {
                                VStack {
                                    HStack {
                                        
                                        if showKD {
                                            PieView(values: [Double(todayKillCount), Double(todayDeathCount)], colors: [.red, Color.gray.opacity(0.5)])
                                                .opacity(0.9)
                                                .frame(width: 25, height: 25)
                                            
                                            Text("K/D:")
                                                .sp2Font(size: 16, color: Color.primary)
                                            
                                            Text("\(Double(todayKillCount) &/ Double(todayDeathCount), places: 1)")
                                                .sp2Font(size: 16, color: Color.secondary)
                                        } else {
                                            PieView(values: [Double(todayKillCount), Double(todayAssistCount), Double(todayDeathCount)], colors: [.red, Color.red.opacity(0.8), Color.gray.opacity(0.5)])
                                                .opacity(0.9)
                                                .frame(width: 25, height: 25)
                                            
                                            Text("KA/D:")
                                                .sp2Font(size: 16, color: Color.primary)
                                            
                                            Text("\(Double(todayKillCount + todayAssistCount) &/ Double(todayDeathCount), places: 1)")
                                                .sp2Font(size: 16, color: Color.secondary)
                                        }
                                        
                                    }
                                    
                                    HStack {
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 4) {
                                            
                                            if showKD {
                                                Text("KILL")
                                                    .sp2Font(size: 10, color: Color.secondary)
                                            
                                                Text("\(todayKillCount)")
                                                    .sp1Font(size: 24, color: .red)
                                                    .minimumScaleFactor(0.5)
                                            } else {
                                                Text("KILL+ASSIST")
                                                    .sp2Font(size: 10, color: Color.secondary)
                                                
                                                Text("\(todayKillCount + todayAssistCount)")
                                                    .sp1Font(size: 24, color: .red)
                                                    .minimumScaleFactor(0.5)
                                            }
                                            
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(spacing: 4) {
                                            
                                            Text("DEATH")
                                                .sp2Font(size: 10, color: Color.secondary)
                                            
                                            Text("\(todayDeathCount)")
                                                .sp1Font(size: 24, color: Color.gray.opacity(0.5))
                                                .minimumScaleFactor(0.5)
                                            
                                        }
                                        
                                        Spacer()
                                        
                                    }
                                }
                                .padding()
                                .background(AppColor.listItemBackgroundColor)
                                .cornerRadius(10)
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        
                                        Image(systemName: showKD ? "circle" : "largecircle.fill.circle")
                                            .resizable()
                                            .frame(width: 14, height: 14)
                                            .foregroundColor(Color.gray.opacity(0.3))
                                            .padding([.trailing, .top], 6)
                                    }
                                    
                                    Spacer()
                                }
                            }
                            .onTapGesture {
                                showKD.toggle()
                            }
                            
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
            .background(AppColor.listBackgroundColor)
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(trailing: makeNavigationBarItems())
            .navigationBarHidden(false)
            .onReceive(homeViewModel.$recordTotalCount) { _ in
                vdChartData = homeViewModel.vdWithLast500
                (todayVictoryCount, todayDefeatCount) = homeViewModel.todayVictoryAndDefeatCount
                (todayKillCount, todayAssistCount, todayDeathCount) = homeViewModel.todayKillAssistAndDeathCount
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
        .background(AppColor.listItemBackgroundColor)
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
