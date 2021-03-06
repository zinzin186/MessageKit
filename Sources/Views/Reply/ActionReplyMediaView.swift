//
//  ActionReplyMediaView.swift
//  MessageKit
//
//  Created by Gapo on 10/9/20.
//

open class ActionReplyMediaView: UIView {
    
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
        imageView.frame = CGRect(contentInset.left, contentInset.top, MKMessageConstant.ActionView.ReplyView.mediaSize.width, MKMessageConstant.ActionView.ReplyView.mediaSize.height)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInset.left),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInset.top),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentInset.bottom)
        ])
        self.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            messageLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor, constant: 0),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -contentInset.right),
        ])

    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
}
