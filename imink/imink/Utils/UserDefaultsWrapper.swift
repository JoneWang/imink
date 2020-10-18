//
//  UserDefaultsWrapper.swift
//  imink
//
//  Created by Jone Wang on 2020/9/7.
//

import Foundation
import SwiftUI

@propertyWrapper
struct StandardStorage<Value: Codable>: DynamicProperty {
    @State var value: Value? = nil
    var key: String
    var store: UserDefaults?
    
    var wrappedValue: Value? {
        get {
            var ud = UserDefaults.standard
            if let store = store {
                ud = store
            }
            
            if let jsonString = ud.string(forKey: key),
               let object = jsonString.decode(Value.self) {
                return object
            }

            return nil
        }
        set {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            var ud = UserDefaults.standard
            if let store = store {
                ud = store
            }
            
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue) {
                let jsonString = String(data: data, encoding: .utf8)
                ud.setValue(jsonString, forKey: key)
            } else {
                ud.setValue(nil, forKey: key)
            }
        }
    }
    
    public var projectedValue: Binding<Value?> {
        $value.projectedValue
    }
}
