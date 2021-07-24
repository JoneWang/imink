//
//  WidgetSizeEnvironmentKey.swift
//  WidgetExtension
//
//  Created by Jone Wang on 2021/7/24.
//

import SwiftUI

private struct WidgetSizeEnvironmentKey: EnvironmentKey {
    static let defaultValue: CGSize = .zero
}

extension EnvironmentValues {
    var widgetSize: CGSize {
        get { self[WidgetSizeEnvironmentKey.self] }
        set { self[WidgetSizeEnvironmentKey.self] = newValue }
    }
}

extension View {
    func widgetSize(_ widgetSize: CGSize) -> some View {
        environment(\.widgetSize, widgetSize)
    }
}
