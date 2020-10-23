//
//  SP2NicknameAndIcons.swift
//  imink
//
//  Created by Jone Wang on 2020/10/14.
//

import Foundation

struct SP2NicknameAndIcon: Codable {
    
    let nicknameAndIcons: [NicknameAndIcon]
    
    struct NicknameAndIcon: Codable {
        let nsaId: String
        let nickname: String
        let thumbnailUrl: String
    }
    
}

extension SP2NicknameAndIcon.NicknameAndIcon {
    
    var avatarURL: URL {
        URL(string: thumbnailUrl)!
    }
    
}
