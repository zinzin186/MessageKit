//
//  ReplyTextView.swift
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
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageLabel: UILabel = {[unowned self] in
        let label: UILabel = .init()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.fromHexCode("#808080")
//        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(messageLabel)
        let contentInset = MKMessageConstant.ActionView.ReplyView.contentMediaInset
        let imageHeight: CGFloat = frame.height - contentInset.vertical
        imageView.frame = CGRect(contentInset.left, contentInset.top, imageHeight, imageHeight)
        let originX: CGFloat = imageView.frame.maxX + 5
        messageLabel.frame = CGRect(originX, imageView.frame.origin.y, frame.width - originX, imageView.frame.height)
    }
   
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
