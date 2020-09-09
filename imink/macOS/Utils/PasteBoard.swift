//
//  PasteBoard.swift
//  imink (MacOS)
//
//  Created by Jone Wang on 2020/9/4.
//

import AppKit

struct PasteBoard {
    static func getString() -> String? {
        NSPasteboard.general.string(forType: .string)
    }
}
