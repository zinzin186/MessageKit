//
//  ReplyTextView.swift
//  MessageKit
//
//  Created by Gapo on 10/9/20.
//

import Lottie

open class ActionReplyMediaView: UIView {
    
    lazy var animationReplyView: AnimationView = {
        let view = AnimationView()
        view.loopMode = .loop
        view.isHidden = true
        return view
    }()
    
    lazy var imageView: UIImageView = {[unowned self] in
        let imageView: UIImageView = .init()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = MKMessageConstant.ActionView.ReplyView.mediaRadius
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageLabel: UILabel = {[unowned self] in
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.fromHexCode("#808080")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    init() {
        super.init(frame: .zero)
        self.addSubview(imageView)
        let contentInset = MKMessageConstant.ActionView.ReplyView.contentMediaInset
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInset.left),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInset.top),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentInset.bottom)
        ])
        self.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            messageLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentInset.right),
        ])
//        imageView.addSubview(animationReplyView)
//        animationReplyView.fillSuperview()
//        self.loadReplyLottie("https://files-5.gapo.vn/sticker/origin/0b58cc57-93f1-4427-b461-17a9c526b1b2.json")
    }
    
    func loadAnimationSticker(_ url: URL) {
        imageView.addSubview(animationReplyView)
        imageView.image = nil
        animationReplyView.fillSuperview()
        Animation.loadedFrom(url: url, closure: { [weak self] (animation) in
            guard let self = self else {return}
            self.animationReplyView.isHidden = false
            self.animationReplyView.animation = animation
            self.animationReplyView.play()
            }, animationCache: LRUAnimationCache.sharedCache)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
