//
//  PieView.swift
//  imink
//
//  Created by Jone Wang on 2020/10/10.
//

import SwiftUI

struct PieView: View {
    let value1: Double
    let value2: Double
    let color1: Color
    let color2: Color
    
    private var endAngle: Double {
        360 * (value2 / (value1 + value2))
    }
    
    var body: some View {
        GeometryReader { geo in
            let radius = geo.size.width / 2
            
            Rectangle()
                .foregroundColor((value1 > 0 && value2 == 0) ? color1 : color2)
                .clipShape(Capsule())
            
            if value1 > 0 {
                Path { path in

                    path.move(to: .init(x: radius, y: radius))
                    path.addArc(
                        center: .init(x: radius, y: radius),
                        radius: radius,
                        startAngle: .degrees(0),
                        endAngle: .degrees(endAngle),
                        clockwise: true
                    )

                }
                .fill(color1)
            }
            
        }
    }
    
}

struct PieView_Previews: PreviewProvider {
    static var previews: some View {
        PieView(value1: 1, value2: 10, color1: AppColor.spPink, color2: AppColor.spLightGreen)
            .frame(width: 50, height: 50)
            .previewLayout(.sizeThatFits)
        PieView(value1: 10, value2: 0, color1: AppColor.spPink, color2: AppColor.spLightGreen)
            .frame(width: 50, height: 50)
            .previewLayout(.sizeThatFits)
    }
}
