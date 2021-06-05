//
//  PieView.swift
//  imink
//
//  Created by Jone Wang on 2020/10/10.
//

import SwiftUI

struct PieView: View {
    let values: [Double]
    let colors: [Color]
    
    var body: some View {
        GeometryReader { geo in
            let radius = geo.size.width / 2
            
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            ForEach(0..<values.count) { index in
                self.makeCircularSector(index: index, radius: radius)
            }
            
        }
    }
    
    func makeCircularSector(index: Int, radius: CGFloat) -> some View {
        let startAngle = 360 * (values[0..<index].reduce(0, +) / values.reduce(0, +)) + 90
        
        let value = values[index]
        let color = colors[index]
        
        let endAngle = startAngle + 360 * (value / values.reduce(0, +))
        
        let view = Path { path in
            
            path.move(to: .init(x: radius, y: radius))
            path.addArc(
                center: .init(x: radius, y: radius),
                radius: radius,
                startAngle: .degrees(startAngle),
                endAngle: .degrees(endAngle),
                clockwise: false
            )
            
        }
        .fill(color)
        
        return view
    }
    
}

struct PieView_Previews: PreviewProvider {
    static var previews: some View {
        PieView(values: [1, 2, 10], colors: [.red, .green, .blue])
            .frame(width: 50, height: 50)
            .previewLayout(.sizeThatFits)
        PieView(values: [1, 0], colors: [AppColor.spPink, AppColor.spLightGreen])
            .frame(width: 50, height: 50)
            .previewLayout(.sizeThatFits)
    }
}
