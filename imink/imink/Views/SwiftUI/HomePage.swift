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
                        
                        Text("# Results (Last 500)")
                            .sp2Font(size: 20, color: Color.primary)
                        
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
                vdChartData = homeViewModel.vdWithLast500
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
