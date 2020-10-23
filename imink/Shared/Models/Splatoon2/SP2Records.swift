//
//  SP2Records.swift
//  imink
//
//  Created by Jone Wang on 2020/10/14.
//

import Foundation

struct SP2Records: Codable {
    
    let records: Records
    
    struct Records: Codable {
        
        let player: SP2Player
        
    }
    
}
