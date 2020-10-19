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
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var messageLabel: UILabel = {[unowned self] in
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.fromHexCode("#808080")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    

    init() {
        super.init(frame: .zero)
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -28)
        ])
        self.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            messageLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            messageLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 5),
            messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
        ])
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   
}
