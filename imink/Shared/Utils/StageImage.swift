//
//  StageImage.swift
//  imink
//
//  Created by ddddxxx on 2021/3/31.
//

import SplatNet2

private let stageImageNameMap = [
    "Spawning Grounds_img": "Spawning Grounds",
    "シェケナダム_img": "Spawning Grounds",
    "Marooner's Bay_img": "Marooner's Bay",
    "難破船ドン・ブラコ_img": "Marooner's Bay",
    "Lost Outpost_img": "Lost Outpost",
    "海上集落シャケト場_img": "Lost Outpost",
    "Salmonid Smokeyard_img": "Salmonid Smokeyard",
    "トキシラズいぶし工房_img": "Salmonid Smokeyard",
    "Ruins of Ark Polaris_img": "Ruins of Ark Polaris",
    "朽ちた箱舟 ポラリス_img": "Ruins of Ark Polaris",
]

extension SalmonRunSchedules.Schedule.Stage {
    
    var imageName: String? {
        return stageImageNameMap[name]
    }
}
