//
//  SalmonRunSchedules.swift
//  imink
//
//  Created by 王强 on 2020/10/6.
//

import Foundation

struct SP2SalmonRunSchedules: Codable {
    
    let schedules: [Schedule]
    let details: [Schedule]
    
    struct Schedule: Codable {
        let startTime: TimeInterval
        let endTime: TimeInterval
        let stage: Stage?
        let weapons: [Weapon]?
        
        struct Stage: Codable {
            let name: String
            let image: String
        }
        
        struct Weapon: Codable {
            let id: String
            let weapon: WeaponDetail?
            let coopSpecialWeapon: CoopSpecialWeapon?
            
            struct WeaponDetail: Codable {
                let id: String
                let name: String
                let thumbnail: String
                let image: String
            }
            
            struct CoopSpecialWeapon: Codable {
                let name: String
                let image: String
            }
        }
        
    }
    
}

extension SP2SalmonRunSchedules.Schedule {
    
    var startDate: Date {
        Date(timeIntervalSince1970: startTime)
    }
    
    var endDate: Date {
        Date(timeIntervalSince1970: endTime)
    }
    
}

extension SP2SalmonRunSchedules.Schedule.Stage {
    
    var imageURL: URL {
        Splatoon2API.host.appendingPathComponent(image)
    }
    
}

extension SP2SalmonRunSchedules.Schedule.Weapon.WeaponDetail {
    
    var thumbnailURL: URL {
        Splatoon2API.host.appendingPathComponent(thumbnail)
    }
    
}

extension SP2SalmonRunSchedules.Schedule.Weapon.CoopSpecialWeapon {
    
    var imageURL: URL {
        Splatoon2API.host.appendingPathComponent(image)
    }
    
}
