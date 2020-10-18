//
//  Collection.swift
//  imink
//
//  Created by Jone Wang on 2020/9/6.
//

import Foundation

extension Collection {
    subscript(optional i: Index) -> Iterator.Element? {
        return self.indices.contains(i) ? self[i] : nil
    }
}
