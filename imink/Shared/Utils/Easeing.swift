//
//  Animation+concave.swift
//  Concave
//
//  Created by Justin Almering on 21/6/19.
//  Copyright © 2019 Justin Almering. All rights reserved.
//
//  https://easings.net

import SwiftUI

extension Animation {
    public static func easeInSine(duration: Double) -> Animation {
        return .timingCurve(0.32, 0, 0.6, 0.36, duration: duration)
    }
    
    public static func easeOutSine(duration: Double) -> Animation {
        return .timingCurve(0.4, 0.64, 0.68, 1, duration: duration)
    }
    
    public static func easeInOutSine(duration: Double) -> Animation {
        return .timingCurve(0.36, 0, 0.64, 1, duration: duration)
    }
    
    public static func easeInCubic(duration: Double) -> Animation {
        return .timingCurve(0.4, 0, 0.68, 0.06, duration: duration)
    }
    
    public static func easeOutCubic(duration: Double) -> Animation {
        return .timingCurve(0.32, 0.94, 0.6, 1, duration: duration)
    }
    
    public static func easeInOutCubic(duration: Double) -> Animation {
        return .timingCurve(0.66, 0, 0.34, 1, duration: duration)
    }
    
    public static func easeInQuint(duration: Double) -> Animation {
        return .timingCurve(0.64, 0, 0.78, 0, duration: duration)
    }
    
    public static func easeOutQuint(duration: Double) -> Animation {
        return .timingCurve(0.22, 1, 0.36, 1, duration: duration)
    }
    
    public static func easeInOutQuint(duration: Double) -> Animation {
        return .timingCurve(0.84, 0, 0.16, 1, duration: duration)
    }
    
    public static func easeInCirc(duration: Double) -> Animation {
        return .timingCurve(0.54, 0, 1, 0.44, duration: duration)
    }
    
    public static func easeOutCirc(duration: Double) -> Animation {
        return .timingCurve(0, 0.56, 0.46, 1, duration: duration)
    }
    
    public static func easeInOutCirc(duration: Double) -> Animation {
        return .timingCurve(0.66, 0, 0.34, 1, duration: duration)
    }

    public static func easeInQuad(duration: Double) -> Animation {
        return .timingCurve(0.26, 0, 0.6, 0.2, duration: duration)
    }
    
    public static func easeOutQuad(duration: Double) -> Animation {
        return .timingCurve(0.4, 0.8, 0.74, 1, duration: duration)
    }
    
    public static func easeInOutQuad(duration: Double) -> Animation {
        return .timingCurve(0.48, 0.04, 0.52, 0.96, duration: duration)
    }
    
    public static func easeInQuart(duration: Double) -> Animation {
        return .timingCurve(0.52, 0, 0.74, 0, duration: duration)
    }
    
    public static func easeOutQuart(duration: Double) -> Animation {
        return .timingCurve(0.4, 0.8, 0.74, 1, duration: duration)
    }
    
    public static func easeInOutQuart(duration: Double) -> Animation {
        return .timingCurve(0.76, 0, 0.24, 1, duration: duration)
    }
    
    public static func easeInExpo(duration: Double) -> Animation {
        return .timingCurve(0.66, 0, 0.86, 0, duration: duration)
    }
    
    public static func easeOutExpo(duration: Double) -> Animation {
        return .timingCurve(0.14, 1, 0.34, 1, duration: duration)
    }
    
    public static func easeInOutExpo(duration: Double) -> Animation {
        return .timingCurve(0.9, 0, 0.1, 1, duration: duration)
    }
    
    public static func easeInBack(duration: Double) -> Animation {
        return .timingCurve(0.6, -0.28, 0.735, 0.045, duration: duration)
    }
    
    public static func easeOutBack(duration: Double) -> Animation {
        return .timingCurve(0.175, 0.885, 0.32, 1.275, duration: duration)
    }
    
    public static func easeInOutBack(duration: Double) -> Animation {
        return .timingCurve(0.68, -0.55, 0.265, 1.55, duration: duration)
    }
}
