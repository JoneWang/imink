//
//  WeaponView.swift
//  InkCore
//
//  Created by Jone Wang on 2021/1/3.
//

import SwiftUI
import UIKit
import SDWebImageSwiftUI

public struct WeaponImageView: View {
    
    var id: String
    var imageURL: URL?
    
    public init(id: String, imageURL: URL? = nil) {
        self.id = id
        self.imageURL = imageURL
    }
    
    public var body: some View {
        let imageName = "weapon-\(id)"
        ImageView(imageName: imageName, imageURL: imageURL, imageURLBehaviour: .standby)
    }
}

struct WeaponView_Previews: PreviewProvider {
    static var previews: some View {
        WeaponImageView(id: "0")
    }
}
