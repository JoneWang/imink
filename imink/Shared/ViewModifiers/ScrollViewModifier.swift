//
//  ScrollViewPagingModifier.swift
//  imink
//
//  Created by Jone Wang on 2022/3/2.
//

import Introspect
import SwiftUI

extension View {
    func scrollViewPaging() -> some View {
        introspectScrollView {
            $0.isPagingEnabled = true
        }
    }
}
