//
//  VDGridView.swift
//  imink
//
//  Created by Jone Wang on 2020/10/8.
//

import SwiftUI

struct VDGridView: View {
    
    enum ItemStatus: Int, CaseIterable {
        case victory
        case defeat
        case none
    }
    
    var data: [Bool]
    @Binding var height: CGFloat
    
    private var dataSource: [(Double, ItemStatus)] {
        let data = Array(self.data.reversed())
        let haveResultStartIndex = Int(count) - data.count
        let indexs = (0..<Int(count))
        return indexs.map { i in
            var itemStatus = ItemStatus.none
            if i >= haveResultStartIndex {
                itemStatus = data[i - haveResultStartIndex] ? .victory : .defeat
            }
            
            return (Double(i), itemStatus)
        }
    }
    
    private var columns: [GridItem] {
        (0..<10).map { _ in GridItem(.adaptive(minimum: 6), spacing: 1) }
    }
    
    private let count: Double = 500
    private let rowCount: Double = 10
    private let itemMargin: Double = 1
    
    var body: some View {
        GeometryReader { geo in
            makeGrid(geo: geo)
        }
    }
    
    func makeGrid(geo: GeometryProxy) -> some View {
        let size = Double(geo.size.width - 18.0) / (count / rowCount) - itemMargin
        height = CGFloat(size * rowCount + (rowCount - 1))
        
        return LazyHGrid(rows: [GridItem(.adaptive(minimum: CGFloat(size)), spacing: CGFloat(itemMargin))], spacing: CGFloat(itemMargin)) {
            
            ForEach(dataSource, id: \.0) { (index, itemStatus) in
                
                if index / rowCount > 1, Int(index / rowCount) % 5 == 0 {
                    Rectangle()
                        .foregroundColor(itemStatus.color)
                        .aspectRatio(1, contentMode: .fill)
                        .padding(.leading, 2)
                } else {
                    Rectangle()
                        .foregroundColor(itemStatus.color)
                        .aspectRatio(1, contentMode: .fill)
                }
            }
            
        }
        .frame(width: geo.size.width, height: height)
    }
}

extension VDGridView.ItemStatus {
    
    var color: Color {
        switch self {
        case .victory:
            return AppColor.spPink.opacity(0.8)
        case .defeat:
            return AppColor.spLightGreen.opacity(0.8)
        case .none:
            return Color.primary.opacity(0.15)
        }
    }
    
}
