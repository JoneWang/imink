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

public extension ImageView {
    
    static func weapon(id: String, imageURL: URL? = nil) -> some View {
        ImageView(imageName: "weapon-\(id)", imageURL: imageURL, imageURLBehaviour: .standby)
    }
    
    static func stage(id: String, imageURL: URL? = nil, imageURLBehaviour: ImageView.ImageURLBehaviour = .standby) -> some View {
        ImageView(imageName: "stage-\(id)", imageURL: imageURL, imageURLBehaviour: imageURLBehaviour)
    }
    
    static func salomonRunStage(name: String, imageURL: URL? = nil, imageURLBehaviour: ImageView.ImageURLBehaviour = .standby) -> some View {
        ImageView(imageName: name, imageURL: imageURL, imageURLBehaviour: imageURLBehaviour)
    }
    
    static func ability(id: String, imageURL: URL? = nil) -> some View {
        ImageView(imageName: "ability-\(id)", imageURL: imageURL, imageURLBehaviour: .standby)
    }
    
    static func sub(id: String, isA: Bool) -> some View {
        ImageView(imageName: "sub-\(isA ? "a" : "b")-\(id)", imageURLBehaviour: .standby)
    }
    
    static func special(id: String, isA: Bool = true) -> some View {
        ImageView(imageName: "special-\(isA ? "a" : "b")-\(id)", imageURLBehaviour: .standby)
    }
    
    static func head(id: String) -> some View {
        ImageView(imageName: "head-\(id)", imageURLBehaviour: .standby)
    }
    
    static func clothes(id: String) -> some View {
        ImageView(imageName: "clothes-\(id)", imageURLBehaviour: .standby)
    }
    
    static func shoes(id: String) -> some View {
        ImageView(imageName: "shoes-\(id)", imageURLBehaviour: .standby)
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(imageName: "weapon-0")
    }
}
