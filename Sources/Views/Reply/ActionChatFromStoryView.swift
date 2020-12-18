//
//  ActionChatFromStoryView.swift
//  InputBarAccessoryView
//
//  Created by Gapo on 10/15/20.
//

import UIKit

open class ActionChatFromStoryView: UIView {
    
    open lazy var imageView: UIImageView = {[unowned self] in
        let imageView: UIImageView = .init()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = MKMessageConstant.ActionView.StoryView.mediaRadius
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
