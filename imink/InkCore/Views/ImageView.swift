//
//  ImageView.swift
//  InkCore
//
//  Created by Jone Wang on 2021/1/3.
//

import SwiftUI
import SDWebImageSwiftUI

public struct ImageView: View {
    
    public enum ImageURLBehaviour {
        case standby, replace
    }
    
    var imageName: String
    var imageURL: URL?
    var imageURLBehaviour: ImageURLBehaviour
    
    public init(imageName: String, imageURL: URL? = nil, imageURLBehaviour: ImageURLBehaviour = .standby) {
        self.imageName = imageName
        self.imageURL = imageURL
        self.imageURLBehaviour = imageURLBehaviour
    }
    
    public var body: some View {
        if imageURLBehaviour == .replace, let imageURL = imageURL {
            return AnyView(
                WebImage(url: imageURL)
                    .resizable()
                    .placeholder(Image(imageName, bundle: Bundle.inkCore))
            )
        } else {
            if let uiImage = UIImage(named: imageName, in: Bundle.inkCore, with: nil) {
                return AnyView(Image(uiImage: uiImage).resizable())
            } else if let imageURL = imageURL {
                return AnyView(WebImage(url: imageURL).resizable())
            } else {
                return AnyView(Image(imageName, bundle: Bundle.inkCore).resizable())
            }
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(imageName: "weapon-0")
    }
}
