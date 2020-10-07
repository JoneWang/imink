//
//  HomePage.swift
//  imink
//
//  Created by 王强 on 2020/10/1.
//

import SwiftUI
import SwiftUICharts

struct HomePage: View {
    
    @StateObject private var homeViewModel = HomeViewModel()
    
    @State private var scheduleType = 0
    @State private var chartType = 0
    @State private var recordCountChartData = [(String, Double)]()
    @State private var kdChartData = [(String, Double)]()
    
    let chartOrangeStyle = ChartStyle(
        backgroundColor: .white,
        foregroundColor: [ColorGradient(ChartColors.orangeBright, ChartColors.orangeDark)]
    )
    
    var body: some View {
        NavigationView {
            
            ScrollView {
                VStack {
                    
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
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("# Chart (Last month)")
                            .sp2Font(size: 20, color: Color.primary)
                        
                        VStack {
                            
                            Picker(selection: $chartType, label: Text("Picker"), content: {
                                Text("Record Count").tag(0)
                                Text("K/D").tag(1)
                            })
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 230)
                            
                            if chartType == 0 {
                                ChartGrid {
                                    BarChart()
                                }
                                .data(recordCountChartData)
                                .chartStyle(chartOrangeStyle)
                                .frame(height: 100)
                                .minimumScaleFactor(0.1)
                            } else if chartType == 1 {
                                ChartGrid {
                                    LineChart()
                                }
                                .data(kdChartData)
                                .chartStyle(chartOrangeStyle)
                                .frame(height: 100)
                                .minimumScaleFactor(0.1)
                            }
                            
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                HStack {
                                    ForEach(recordCountChartData, id: \.0) { data in
                                        Spacer()
                                        Text("\(data.0)")
                                            .sp2Font(size: 8, color: Color.primary.opacity(0.5))
                                            .minimumScaleFactor(0)
                                        Spacer()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.leading, 5)
                                .padding(.trailing, 10)
                            }
                        }
                        .padding(.top)
                        
                    }
                    .padding(.horizontal)
                    
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
                    .padding([.leading, .trailing, .bottom])
                    .padding(.top, 30)
                    .animation(.default)
                    
                    Spacer()
                }
            }
            .navigationBarTitle("Home", displayMode: .inline)
            .navigationBarItems(trailing: makeNavigationBarItems())
            .navigationBarHidden(false)
            .onReceive(homeViewModel.$recordTotalCount) { _ in
                recordCountChartData = homeViewModel.recordCountForLastMonthChartData
                kdChartData = homeViewModel.kdForLastMonthChartData
            }
            
        }
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
