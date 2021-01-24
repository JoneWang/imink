//
//  File.swift
//  imink
//
//  Created by Jone Wang on 2020/9/2.
//

import SwiftUI

struct AppColor {
    static let appLabelColor = Color("AppLabelColor")
    
    static let spText = Color.white
    
    static let spGreen = Color("SPGreenColor")
    
    static let spGreenLimeColor = Color("SPGreenLimeColor")
    
    static let spPurple = Color("SPPurpleColor")
    
    static let spLime = Color("SPLimeColor")
    
    static let spRed = Color("SPRedColor")
    
    static let spLightGreen = Color("SPLightGreenColor")
    
    static let spPink = Color("SPPinkColor")
    
    static let spYellow = Color("SPYellowColor")
    
    static let spOrange = Color("SPOrangeColor")

    static let recordRowTitleNormalColor = Color("RecordRowTitleNormalColor")
    
    static let recordRowTitleSelectedColor = Color("RecordRowTitleSelectedColor")
    
    static let listBackgroundColor = Color("ListBackgroundColor")
    
    static let listItemBackgroundColor = Color("ListItemBackgroundColor")
    
    static let nintendoRedColor = Color("NintendoRedColor")
    
    static let playerResultSpecialVictoryBackgroundColor = Color("PlayerResultSpecialVictoryBackgroundColor")
    
    static let playerResultSpecialDefeatBackgroundColor = Color("PlayerResultSpecialDefeatBackgroundColor")
        
    static var memberArrowColor: Color {
        Color(AppUIColor.memberArrowColor)
    }
    
    static var battleDetailStreakForegroundColor: Color {
        Color(AppUIColor.battleDetailStreakForegroundColor)
    }
    
    static var waveClearColor: Color {
        Color(AppUIColor.waveClearColor)
    }
    
    static var waveDefeatColor: Color {
        Color(AppUIColor.waveDefeatColor)
    }
    
    static var waveGradientStartColor: Color {
        Color(AppUIColor.waveGradientStartColor)
    }
    
    static var salmonRunSpecialBackgroundColor: Color {
        Color(AppUIColor.salmonRunSpecialBackgroundColor)
    }
}

struct AppUIColor {
    static let appLabelColor = UIColor(named: "AppLabelColor")
    
    static let spText = UIColor.white
    
    static let spGreen = UIColor(named: "SPGreenColor")!
    
    static let spGreenLimeColor = Color("SPGreenLimeColor")
    
    static let spPurple = UIColor(named: "SPPurpleColor")!
    
    static let spLime = UIColor(named: "SPLimeColor")!
    
    static let spRed = UIColor(named: "SPRedColor")!
    
    static let spLightGreen = UIColor(named: "SPLightGreenColor")!
    
    static let spPink = UIColor(named: "SPPinkColor")!
    
    static let spYellow = UIColor(named: "SPYellowColor")!
    
    static let spOrange = UIColor(named: "SPOrangeColor")!
    
    static let spBlue = UIColor.blue
        
    static let recordRowTitleNormalColor = UIColor(named: "RecordRowTitleNormalColor")!
    
    static let recordRowTitleSelectedColor = UIColor(named: "RecordRowTitleSelectedColor")!
    
    static let listBackgroundColor = UIColor(named: "ListBackgroundColor")!
    
    static let listItemBackgroundColor = UIColor(named: "ListItemBackgroundColor")!
    
    static let nintendoRedColor = UIColor(named: "NintendoRedColor")
    
    static let playerResultSpecialVictoryBackgroundColor = UIColor(named: "PlayerResultSpecialVictoryBackgroundColor")
    
    static let playerResultSpecialDefeatBackgroundColor = UIColor(named: "PlayerResultSpecialDefeatBackgroundColor")
    
    static let memberArrowColor = UIColor(named: "MemberArrowColor")!
    
    static let battleDetailStreakForegroundColor = UIColor(named: "BattleDetailStreakForegroundColor")!
    
    static let waveClearColor = UIColor(named: "WaveClearColor")!
    
    static let waveDefeatColor = UIColor(named: "WaveDefeatColor")!
    
    static let waveGradientStartColor = UIColor(named: "WaveGradientStartColor")!
    
    static let salmonRunSpecialBackgroundColor = UIColor(named: "SalmonRunSpecialBackgroundColor")!
}
