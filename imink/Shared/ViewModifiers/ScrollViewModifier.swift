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

extension View {
    func scrollViewScroll(perform action: @escaping (CGPoint) -> Void) -> some View {
        var delegate = ScrollViewDelegate.shared
        if ScrollViewDelegate.shared == nil {
            delegate = ScrollViewDelegate()
            ScrollViewDelegate.shared = delegate
        }
        delegate?.scroll = action
        return introspectScrollView {
            $0.delegate = delegate
        }
    }
}

class ScrollViewDelegate: NSObject {
    static var shared: ScrollViewDelegate?

    var scroll: ((CGPoint) -> Void)?
    init(scroll: @escaping (CGPoint) -> Void) {
        self.scroll = scroll
    }

    override init() { }
}

extension ScrollViewDelegate: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scroll?(scrollView.contentOffset)
    }
}
