//
//  ScrollViewOffset.swift
//  imink
//
//  Created by Jone Wang on 2022/6/3.
//
//  Source: https://github.com/FiveStarsBlog/CodeSamples/tree/main/ScrollView-Offset

import SwiftUI

struct ScrollViewOffset<Content: View>: View {
    let onOffsetChange: (CGPoint) -> Void
    let content: () -> Content
    let axes: Axis.Set
    let showsIndicators: Bool

    init(
        _ axes: Axis.Set,
        showsIndicators: Bool,
        @ViewBuilder content: @escaping () -> Content,
        onOffsetChange: @escaping (CGPoint) -> Void
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onOffsetChange = onOffsetChange
        self.content = content
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            offsetReader
            content()
                .padding(.top, -8)
        }
        .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: onOffsetChange)
    }

    var offsetReader: some View {
        GeometryReader { proxy in
            let x = proxy.frame(in: .named("frameLayer")).minX
            let y = proxy.frame(in: .named("frameLayer")).minY
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: CGPoint(x: -x, y: -y)
                )
        }
        .frame(height: 0)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {}
}
