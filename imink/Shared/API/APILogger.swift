//
//  APILogger.swift
//  imink
//
//  Created by Jone Wang on 2022/5/23.
//

import Foundation

class APILogger {
    public private(set) var log: String = "API Log\n\n"
}

extension APILogger {
    func res(data: Data, response: HTTPURLResponse) {
        log(content: "Url: \(response.url?.absoluteString ?? ""), Code: \(response.statusCode), Body: \(String(data: data, encoding: .utf8) ?? "")")
    }
    
    func err(request: URLRequest, data: Data? = nil, response: HTTPURLResponse? = nil, error: Error? = nil) {
        log(content: "Url: \(request.url?.absoluteString ?? ""), Code: \(response?.statusCode ?? -1), Body: \(data != nil ? (String(data: data!, encoding: .utf8) ?? "") : "none") Error: \(error?.localizedDescription ?? "none")")
    }
}

extension APILogger {
    internal func log(content: String) {
        log.append(contentsOf: "\(content)\n")
    }
}
