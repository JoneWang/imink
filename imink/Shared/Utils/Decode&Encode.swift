//
//  Decode&Encode.swift
//  imink
//
//  Created by Jone Wang on 2020/9/17.
//

import Foundation

extension String {
    
    func decode<T>(_ type: T.Type) -> T? where T : Decodable {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        guard let object = data.decode(type) else {
            return nil
        }
        
        return object
    }
    
}

extension Data {
    
    func decode<T>(_ type: T.Type) -> T? where T : Decodable {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(type.self, from: self)
        } catch {
            print(error)
            return nil
        }
    }
    
}
