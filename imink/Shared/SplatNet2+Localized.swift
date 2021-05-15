//
//  SplatNet2+Localized.swift
//  imink
//
//  Created by Jone Wang on 2021/5/12.
//

let splatNet2L10nTable = "SplatNet2"

extension String {
    
    var splatNet2Localized: String {
        localized(with: splatNet2L10nTable)
    }
}

extension SalmonRunSchedules.Schedule.Stage {
    
    var localizedName: String {
        name.splatNet2Localized
    }
}

extension Stage {
    
    var localizedName: String {
        name.splatNet2Localized
    }
}

extension Job.WaveDetail.WaterLevel {
    
    var localizedName: String {
        key.rawValue.splatNet2Localized
    }
}

extension Job.WaveDetail.EventType {
    
    var localizedName: String {
        key.splatNet2Localized
    }
}

extension GameRule {
    
    var localizedName: String {
        name.splatNet2Localized
    }
}

extension GameMode {
    
    var localizedName: String {
        name.splatNet2Localized
    }
}
