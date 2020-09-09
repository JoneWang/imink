//
//  UserDefaultsWrapper.swift
//  imink
//
//  Created by Jone Wang on 2020/9/7.
//

import Foundation

@propertyWrapper
struct StandardStorage<Value: Codable> {
    var value: Value?
    var key: String

    var wrappedValue: Value? {
        get {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let ud = UserDefaults.standard

            if let jsonString = ud.string(forKey: key),
               let data = jsonString.data(using: .utf8),
               let object = try? decoder.decode(Value.self, from: data) {
                return object
            }

            return nil
        }
        set {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            let ud = UserDefaults.standard
            
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                let jsonString = String(data: data, encoding: .utf8)
                ud.setValue(jsonString, forKey: key)
            } else {
                ud.setValue(nil, forKey: key)
            }
        }
    }
}
