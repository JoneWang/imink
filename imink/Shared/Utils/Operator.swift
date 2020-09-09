//
//  Operator.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

infix operator &/

//extension CGFloat {
//    public static func &/(lhs: CGFloat, rhs: CGFloat) -> CGFloat {
//        if rhs == 0 {
//            return 0
//        }
//        return lhs / rhs
//    }
//}

extension Double {
    public static func &/(lhs: Double, rhs: Double) -> Double {
        if rhs == 0 {
            return 0
        }
        return lhs / rhs
    }
}
