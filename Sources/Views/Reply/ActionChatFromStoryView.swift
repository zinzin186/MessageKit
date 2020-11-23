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

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        imageView.frame = frame
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
