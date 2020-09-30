//
//  ToolbarDelegate.swift
//  imink
//
//  Created by Jone Wang on 2020/9/24.
//

import UIKit

class ToolbarDelegate: NSObject {

}

#if targetEnvironment(macCatalyst)
extension NSToolbarItem.Identifier {
    static let share = NSToolbarItem.Identifier("jone.wang.imink.shareBattle")
//    static let toggleRecipeIsFavorite = NSToolbarItem.Identifier("jone.wang.imink.toggleRecipeIsFavorite")
}

extension ToolbarDelegate {
    
    @objc
    func shareBattle(_ sender: Any) {
        NotificationCenter.default.post(name: .share, object: sender)
    }
    
    @objc
    func toggleRecipeIsFavorite(_ sender: Any) {
//        NotificationCenter.default.post(name: .toggleRecipeIsFavorite, object: self)
    }
    
}

extension ToolbarDelegate: NSToolbarDelegate {
    
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        let identifiers: [NSToolbarItem.Identifier] = [
            .toggleSidebar,
            .flexibleSpace,
            .share,
//            .toggleRecipeIsFavorite
        ]
        return identifiers
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
    
    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        
        var toolbarItem: NSToolbarItem?
        
        switch itemIdentifier {
        case .toggleSidebar:
            toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        case .share:
//            let item = NSSharingServicePickerToolbarItem(itemIdentifier: .share)
//            item.activityItemsConfiguration = rootViewController
//            return item
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.image = UIImage(systemName: "square.and.arrow.up")
            item.label = "Share Battle"
            item.action = #selector(shareBattle(_:))
            item.target = self
            item.isBordered = true
            toolbarItem = item

//        case .toggleRecipeIsFavorite:
//            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
//            item.image = UIImage(systemName: "heart")
//            item.label = "Toggle Favorite"
//            item.action = #selector(toggleRecipeIsFavorite(_:))
//            item.target = self
//            toolbarItem = item
            
        default:
            toolbarItem = nil
        }
        
        return toolbarItem
    }
    
}
#endif
