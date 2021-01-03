//
//  SalomonRunImageView.swift
//  InkCore
//
//  Created by Jone Wang on 2021/1/3.
//

import SwiftUI

public struct SalomonRunStageImageView: View {
    
    var name: String
    var imageURL: URL?
    var imageURLBehaviour: ImageView.ImageURLBehaviour
    
    public init(name: String, imageURL: URL? = nil, imageURLBehaviour: ImageView.ImageURLBehaviour = .standby) {
        self.name = name
        self.imageURL = imageURL
        self.imageURLBehaviour = imageURLBehaviour
    }
    
    public var body: some View {
        let imageName = "\(name)_img"
        ImageView(imageName: imageName, imageURL: imageURL, imageURLBehaviour: imageURLBehaviour)
    }
}

struct SalomonRunImageView_Previews: PreviewProvider {
    static var previews: some View {
        SalomonRunStageImageView(name: "Lost Outpost")
    }
}
