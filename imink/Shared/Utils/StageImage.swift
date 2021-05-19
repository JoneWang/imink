//
//  StageImage.swift
//  imink
//
//  Created by ddddxxx on 2021/3/31.
//

import SplatNet2

private let stageImageNameMap = [
    "Spawning Grounds": "Spawning Grounds",
    "シェケナダム": "Spawning Grounds",
    "Marooner's Bay": "Marooner's Bay",
    "難破船ドン・ブラコ": "Marooner's Bay",
    "Lost Outpost": "Lost Outpost",
    "海上集落シャケト場": "Lost Outpost",
    "Salmonid Smokeyard": "Salmonid Smokeyard",
    "トキシラズいぶし工房": "Salmonid Smokeyard",
    "Ruins of Ark Polaris": "Ruins of Ark Polaris",
    "朽ちた箱舟 ポラリス": "Ruins of Ark Polaris",
]

extension SalmonRunSchedules.Schedule.Stage {
    
    var imageName: String? {
        return stageImageNameMap[name]
    }
}
