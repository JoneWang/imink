//
//  FixVectorImage.swift
//  InkCore
//
//  Created by Jone Wang on 2021/3/10.
//

import SwiftUI

public struct FixVectorImage: UIViewRepresentable {
    
    var name: String
    var contentMode: UIView.ContentMode = .scaleAspectFit
    var tintColor: Color? = nil
    
    public init(
        _ name: String,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        tintColor: Color? = nil
    ) {
        self.name = name
        self.contentMode = contentMode
        self.tintColor = tintColor
    }
    
    public func makeUIView(context: Context) -> UIImageView {
        let imageView = UIImageView()
        imageView.setContentCompressionResistancePriority(
            .fittingSizeLevel,
            for: .vertical
        )
        return imageView
    }
    
    public func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.contentMode = contentMode
        
        guard var image = UIImage(named: name) else {
            return
        }
        
        if let tintColor = tintColor {
            image = image.withRenderingMode(.alwaysTemplate)
            uiView.tintColor = UIColor(tintColor)
        }
        
        uiView.image = image
    }
}
