//
//  SP2ActiveFestivals.swift
//  imink
//
//  Created by Jone Wang on 2020/10/18.
//

import Foundation
import SwiftUI

struct SP2ActiveFestivals: Codable {
    
    let festivals: [Festival]
    
    struct Festival: Codable {
        let images: FestivalImages
        let names: FestivalNames
        let colors: FestivalColors
        let times: FestivalTimes
        
        struct FestivalImages: Codable {
            let alpha: String
            let panel: String
            let bravo: String
        }
        
        struct FestivalNames: Codable {
            let alphaLong: String
            let bravoLong: String
            let alphaShort: String
            let bravoShort: String
        }
        
        struct FestivalColors: Codable {
            let alpha: FestivalColor
            let bravo: FestivalColor
            
            struct FestivalColor: Codable {
                let r: Double
                let g: Double
                let b: Double
                let a: Double
            }
        }
        
        struct FestivalTimes: Codable {
            let result: TimeInterval
            let announce: TimeInterval
            let start: TimeInterval
            let end: TimeInterval
        }
    }
    
}

extension SP2ActiveFestivals.Festival.FestivalImages {
    
    var alphaImageURL: URL {
        Splatoon2API.host.appendingPathComponent(alpha)
    }
    
    var bravoImageURL: URL {
        Splatoon2API.host.appendingPathComponent(bravo)
    }
    
    var panelImageURL: URL {
        Splatoon2API.host.appendingPathComponent(panel)
    }
    
}

extension SP2ActiveFestivals.Festival.FestivalColors {
    
    var alphaColor: Color {
        Color(.displayP3, red: alpha.r, green: alpha.g, blue: alpha.b, opacity: alpha.a)
    }
    
    var bravoColor: Color {
        Color(.displayP3, red: bravo.r, green: bravo.g, blue: bravo.b, opacity: bravo.a)
    }
    
}

extension SP2ActiveFestivals.Festival.FestivalTimes {
    
    var startDate: Date {
        Date(timeIntervalSince1970: start)
    }
    
    var endDate: Date {
        Date(timeIntervalSince1970: end)
    }
    
}


