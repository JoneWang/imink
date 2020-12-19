//
//  Splatoon2API.swift
//  imink
//
//  Created by Jone Wang on 2020/9/4.
//

import Foundation
import Moya
import SplatNet2API

var sn2Provider: MoyaProvider<SplatNet2API> {
    var plugins: [PluginType] = []
    if let user = AppUserDefaults.shared.user {
        let auth = SplatNet2Auth(iksmSession: user.iksmSession)
        plugins.append(auth)
    }
    return MoyaProvider<SplatNet2API>(plugins: plugins)
}
