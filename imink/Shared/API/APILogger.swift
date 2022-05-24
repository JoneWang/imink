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
    
    func err(_ error: Error) {
        log(content: "Error: \(error.localizedDescription)")
    }
}

extension APILogger {
    internal func log(content: String) {
        log.append(contentsOf: "\(content)\n")
    }
}
