//
//  TargetType.swift
//  imink
//
//  Created by Jone Wang on 2020/9/5.
//

import Foundation

enum APIMethod: String {
    case post = "POST"
    case get = "GET"
    case update = "UPDATE"
    case delete = "DELETE"
    // TODO: Need more
}

enum MediaType {
    case jsonData(_ data: Encodable)
    case form(_ form: [(String, String)])
    // TODO: Need more
}

protocol APITargetType {

    /// The target's base `URL`.
    var baseURL: URL { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: APIMethod { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }
    
    var querys: [(String, String?)]? { get }
    
    var data: MediaType? { get }
}
