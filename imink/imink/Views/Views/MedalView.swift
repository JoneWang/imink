//
//  MedalView.swift
//  imink
//
//  Created by Jone Wang on 2021/5/18.
//

import SwiftUI

struct MedalView: View {
    
    enum MedalType {
        case bronze, silver, gold
    }
    
    let type: MedalType
    let count: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(type.imageName)
            Text("\(count)")
                .sp2Font(size: 13, color: AppColor.appLabelColor)
        }
        .padding(.leading, 3)
        .padding(.trailing, 5)
        .frame(height: 22)
        .background(AppColor.medalViewBackgroundColor)
        .clipShape(Capsule())
    }
}

extension MedalView.MedalType {
    
    var imageName: String {
        switch self {
        case .bronze:
            return "MedalBronze"
        case .silver:
            return "MedalSilver"
        case .gold:
            return "MedalGold"
        }
    }
}

struct MedalView_Previews: PreviewProvider {
    static var previews: some View {
        MedalView(type: .bronze, count: 123)
    }
}
