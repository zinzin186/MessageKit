//
//  ActionChatFromStoryView.swift
//  InputBarAccessoryView
//
//  Created by Gapo on 10/15/20.
//

import UIKit

open class ActionChatFromStoryView: UIView {
    
    lazy var imageView: UIImageView = {[unowned self] in
        let imageView: UIImageView = .init()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init() {
        super.init(frame: .zero)
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: -5),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5)
        ])

    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
