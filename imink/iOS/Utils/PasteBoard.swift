//
//  PasteBoard.swift
//  imink (iOS)
//
//  Created by Jone Wang on 2020/9/4.
//

import UIKit

struct PasteBoard {
    public static func getString() -> String? {
        UIPasteboard.general.string
    }
}
