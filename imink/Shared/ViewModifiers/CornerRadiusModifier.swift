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
    
    func continuousCornerRadius(_ corners: UIRectCorner = .allCorners, _ radius: CGFloat) -> some View {
        self.clipShape(RoundedCorner(corners: corners, radius: radius))
            // FIXME: Performance issues
            .drawingGroup()
    }
}

fileprivate struct RoundedCorner: Shape {
    let corners: UIRectCorner
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
