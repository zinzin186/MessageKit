//
//  StickerMessageCell.swift
//  MessageKit
//
//  Created by Gapo on 10/19/20.
//

import Foundation

open class StickerMessageCell: MessageContentCell {

    /// The play button view to display on video messages.
    
    open var animationView: UIView?
    
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
  
    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.animationView?.removeFromSuperview()
    }

    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        imageView.frame = messageContainerView.bounds
        self.messageContainerView.backgroundColor = UIColor.clear
        displayDelegate.configureStickerImageView(self, for: message, at: indexPath, in: messagesCollectionView)
    }
    
}
