//
//  SP2Weapon.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

struct SP2Weapon: Codable {
    let id: String
    let name: String
    let image: String
    let thumbnail: String
    let sub: Equipment
    let special: Equipment
    
    struct Equipment: Codable {
        let id: String
        let name: String
        let imageA: String
        let imageB: String
    }
}

extension SP2Weapon {
    var imageURL: URL {
        Splatoon2API.host.appendingPathComponent(image)
    }
}

extension SP2Weapon.Equipment {
    var imageAURL: URL {
        Splatoon2API.host.appendingPathComponent(imageA)
    }
    
    var imageBURL: URL {
        Splatoon2API.host.appendingPathComponent(imageB)
    }
}
