//
//  CornerRadiusModifier.swift
//  imink
//
//  Created by Jone Wang on 2020/12/28.
//

import Foundation
import SwiftUI

extension View {
    func continuousCornerRadius(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
    
    func continuousCornerRadius(_ corners: RoundedCorners.Corner = .allCorners, _ radius: CGFloat) -> some View {
        self.clipShape(RoundedCorners(corners: corners, radius: radius))
            // FIXME: Performance issues
            .drawingGroup()
    }
}

struct RoundedCorners: Shape {
    
    struct Corner : OptionSet {
        let rawValue: Int
        
        static var topLeft = Corner(rawValue: 1)
        static var topRight = Corner(rawValue: 2)
        static var bottomLeft = Corner(rawValue: 4)
        static var bottomRight = Corner(rawValue: 8)
        static var allCorners = Corner(rawValue: 512)
    }
    
    let corners: Corner
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        var tl: CGFloat = corners.contains(.topLeft) ? radius : 0
        var tr: CGFloat = corners.contains(.topRight) ? radius : 0
        var bl: CGFloat = corners.contains(.bottomLeft) ? radius : 0
        var br: CGFloat = corners.contains(.bottomRight) ? radius : 0

        let w = rect.size.width
        let h = rect.size.height

        // Make sure we do not exceed the size of the rectangle
        tr = min(min(tr, h/2), w/2)
        tl = min(min(tl, h/2), w/2)
        bl = min(min(bl, h/2), w/2)
        br = min(min(br, h/2), w/2)

        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)

        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)

        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)

        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}
