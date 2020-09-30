//
//  SP2Player.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

struct SP2Player: Codable {
    let principalId: String
    let nickname: String
    let playerRank: Int
    let starRank: Int
    let weapon: SP2Weapon
    let udemae: Udemae?
    let headSkills: ClothingSkill
    let clothesSkills: ClothingSkill
    let shoesSkills: ClothingSkill
    
    struct Udemae: Codable {
        let name: String?
        let sPlusNumber: Int?
        let isX: Bool
    }
    
    struct ClothingSkill: Codable {
        let main: Skill
        let subs: [Skill?]
        
        struct Skill: Codable {
            let id: String
            let name: String
            let image: String
        }
    }
}

extension SP2Player.ClothingSkill.Skill {
    var imageURL: URL {
        Splatoon2API.host.appendingPathComponent(image)
    }
}
