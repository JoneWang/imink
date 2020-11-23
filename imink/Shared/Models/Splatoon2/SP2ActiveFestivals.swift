//
//  SP2ActiveFestivals.swift
//  imink
//
//  Created by Jone Wang on 2020/10/18.
//

import SplatNet2
import SwiftUI

typealias SP2ActiveFestivals = SplatNet2.ActiveFestivals

extension SP2ActiveFestivals {
    typealias Festival = SplatNet2.Festival
}

extension SP2ActiveFestivals.Festival.FestivalColors {
    
    var alphaColor: Color {
        Color(.displayP3, red: alpha.r, green: alpha.g, blue: alpha.b, opacity: alpha.a)
    }
    
    var bravoColor: Color {
        Color(.displayP3, red: bravo.r, green: bravo.g, blue: bravo.b, opacity: bravo.a)
    }
    
}
