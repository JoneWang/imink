//
//  StageView.swift
//  InkCore
//
//  Created by Jone Wang on 2021/1/3.
//

import SwiftUI
import SDWebImageSwiftUI

public struct StageImageView: View {
    
    var id: String
    var imageURL: URL?
    var imageURLBehaviour: ImageView.ImageURLBehaviour
    
    public init(id: String, imageURL: URL? = nil, imageURLBehaviour: ImageView.ImageURLBehaviour = .standby) {
        self.id = id
        self.imageURL = imageURL
        self.imageURLBehaviour = imageURLBehaviour
    }
    
    public var body: some View {
        let imageName = "stage-\(id)"
        ImageView(imageName: imageName, imageURL: imageURL, imageURLBehaviour: imageURLBehaviour)
    }
}

struct StageView_Previews: PreviewProvider {
    static var previews: some View {
        StageImageView(id: "0")
    }
}
