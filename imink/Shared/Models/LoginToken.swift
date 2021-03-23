//
//  LoginToken.swift
//  imink
//
//  Created by Jone Wang on 2021/3/21.
//

import Foundation

struct LoginToken: Codable {
    let scope: [String]
    let accessToken: String
    let idToken: String
    let tokenType: String
    let expiresIn: Int
}
