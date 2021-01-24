//
//  WaveShape.swift
//  imink
//
//  Created by Jone Wang on 2021/1/22.
//

import SwiftUI

struct WaveShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let waveHeight: CGFloat = 16
        let height = rect.size.height
        
        path.move(to: CGPoint(x: 0.932*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.824*width, y: 0.5*waveHeight), control1: CGPoint(x: 0.878*width, y: 0), control2: CGPoint(x: 0.878*width, y: 0.5*waveHeight))
        path.addCurve(to: CGPoint(x: 0.7159*width, y: 0), control1: CGPoint(x: 0.77*width, y: 0.5*waveHeight), control2: CGPoint(x: 0.77*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.6079*width, y: 0.5*waveHeight), control1: CGPoint(x: 0.6619*width, y: 0), control2: CGPoint(x: 0.6619*width, y: 0.5*waveHeight))
        path.addCurve(to: CGPoint(x: 0.4999*width, y: 0), control1: CGPoint(x: 0.5539*width, y: 0.5*waveHeight), control2: CGPoint(x: 0.5539*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.3919*width, y: 0.5*waveHeight), control1: CGPoint(x: 0.4459*width, y: 0), control2: CGPoint(x: 0.4459*width, y: 0.5*waveHeight))
        path.addCurve(to: CGPoint(x: 0.2839*width, y: 0), control1: CGPoint(x: 0.3379*width, y: 0.5*waveHeight), control2: CGPoint(x: 0.3379*width, y: 0))
        path.addCurve(to: CGPoint(x: 0.176*width, y: 0.5*waveHeight), control1: CGPoint(x: 0.2299*width, y: 0), control2: CGPoint(x: 0.23*width, y: 0.5*waveHeight))
        path.addCurve(to: CGPoint(x: 0.068*width, y: 0), control1: CGPoint(x: 0.122*width, y: 0.5*waveHeight), control2: CGPoint(x: 0.122*width, y: 0))
        path.addCurve(to: CGPoint(x: 0, y: 0.36938*waveHeight), control1: CGPoint(x: 0.032*width, y: 0), control2: CGPoint(x: 0.02*width, y: 0.22125*waveHeight))
        path.addLine(to: CGPoint(x: 0*width, y: 1*height))
        path.addLine(to: CGPoint(x: 1*width, y: 1*height))
        path.addLine(to: CGPoint(x: 1*width, y: 0.36938*waveHeight))
        path.addCurve(to: CGPoint(x: 0.932*width, y: 0), control1: CGPoint(x: 0.98*width, y: 0.22125*waveHeight), control2: CGPoint(x: 0.968*width, y: 0))
        path.closeSubpath()
        
        return path
    }
}

struct WaveShape_Previews: PreviewProvider {
    static var previews: some View {
        WaveShape()
            .previewLayout(.fixed(width: 100.0, height: 16))
        
        WaveShape()
            .previewLayout(.fixed(width: 100.0, height: 50))
        
        WaveShape()
            .previewLayout(.fixed(width: 100.0, height: 100.0))
    }
}
