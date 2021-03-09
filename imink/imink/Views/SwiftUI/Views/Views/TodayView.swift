//
//  TodayView.swift
//  imink
//
//  Created by Jone Wang on 2021/3/9.
//

import SwiftUI

struct TodayView: View {
    
    let today: Today
    
    @AppStorage("showKDInHome")
    private var showKD: Bool = false
    
    var body: some View {
        HStack(spacing: 8) {
            
            VStack {
                HStack {
                    
                    PieView(values: [Double(today.victoryCount), Double(today.defeatCount)], colors: [AppColor.spPink, AppColor.spLightGreen])
                        .opacity(0.9)
                        .frame(width: 25, height: 25)
                    
                    Text("Victory rate:")
                        .sp2Font(size: 16, color: AppColor.appLabelColor)
                        .minimumScaleFactor(0.5)
                    
                    Text("\((Double(today.victoryCount) &/ Double(today.victoryCount + today.defeatCount)) * 100)%")
                        .sp2Font(size: 16, color: Color.secondary)
                    
                }
                
                HStack {
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        
                        Text("VICTORY")
                            .sp2Font(size: 10, color: Color.secondary)
                        
                        Text("\(today.victoryCount)")
                            .sp1Font(size: 24, color: AppColor.spPink)
                            .minimumScaleFactor(0.5)
                        
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        
                        Text("DEFEAT")
                            .sp2Font(size: 10, color: Color.secondary)
                        
                        Text("\(today.defeatCount)")
                            .sp1Font(size: 24, color: AppColor.spLightGreen)
                            .minimumScaleFactor(0.5)
                        
                    }
                    
                    Spacer()
                    
                }
            }
            .padding([.top, .bottom])
            .background(AppColor.listItemBackgroundColor)
            .continuousCornerRadius(10)
            
            ZStack {
                VStack {
                    HStack {
                        
                        if showKD {
                            PieView(values: [Double(today.killCount), Double(today.deathCount)], colors: [.red, Color.gray.opacity(0.5)])
                                .opacity(0.9)
                                .frame(width: 25, height: 25)
                            
                            Text("K/D:")
                                .sp2Font(size: 16, color: AppColor.appLabelColor)
                            
                            Text("\(Double(today.killCount) &/ Double(today.deathCount), places: 1)")
                                .sp2Font(size: 16, color: Color.secondary)
                        } else {
                            PieView(values: [Double(today.killCount), Double(today.assistCount), Double(today.deathCount)], colors: [.red, Color.red.opacity(0.8), Color.gray.opacity(0.5)])
                                .opacity(0.9)
                                .frame(width: 25, height: 25)
                            
                            Text("KA/D:")
                                .sp2Font(size: 16, color: AppColor.appLabelColor)
                            
                            Text("\(Double(today.killCount + today.assistCount) &/ Double(today.deathCount), places: 1)")
                                .sp2Font(size: 16, color: Color.secondary)
                        }
                        
                    }
                    
                    HStack {
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            
                            if showKD {
                                Text("KILL")
                                    .sp2Font(size: 10, color: Color.secondary)
                                
                                Text("\(today.killCount)")
                                    .sp1Font(size: 24, color: .red)
                                    .minimumScaleFactor(0.5)
                            } else {
                                Text("KILL+ASSIST")
                                    .sp2Font(size: 10, color: Color.secondary)
                                
                                Text("\(today.killCount + today.assistCount)")
                                    .sp1Font(size: 24, color: .red)
                                    .minimumScaleFactor(0.5)
                            }
                            
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            
                            Text("DEATH")
                                .sp2Font(size: 10, color: Color.secondary)
                            
                            Text("\(today.deathCount)")
                                .sp1Font(size: 24, color: Color.gray.opacity(0.5))
                                .minimumScaleFactor(0.5)
                            
                        }
                        
                        Spacer()
                        
                    }
                }
                .padding([.top, .bottom])
                .background(AppColor.listItemBackgroundColor)
                .continuousCornerRadius(10)
                
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
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(today: Today())
    }
}
