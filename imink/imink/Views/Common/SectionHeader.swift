//
//  SectionFooter.swift
//  imink
//
//  Created by Jone Wang on 2021/6/8.
//

import SwiftUI

struct SectionHeader<Content: View> : View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        // FIXME: iOS 14 no horizontal padding
        if #available(iOS 15.0, *) {
            content
        } else {
            content
                .padding(.horizontal, 16)
        }
    }
}

typealias SectionFooter = SectionHeader
