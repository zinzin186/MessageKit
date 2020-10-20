//
//  StickerMessageCell.swift
//  MessageKit
//
//  Created by Gapo on 10/19/20.
//

import Foundation
import Lottie

open class StickerMessageCell: MediaMessageCell {
    
    let animationView = AnimationView()
    
    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        switch message.kind {
        case .sticker(let mediaItem):
            if let url = mediaItem.url {
                messageContainerView.backgroundColor = UIColor.clear
                let isLottie = url.absoluteString.hasSuffix("json")
                self.animationView.isHidden = !isLottie
                self.imageView.isHidden = isLottie
                if isLottie {
                    setupViewBodySticker()
                    Animation.loadedFrom(url: url, closure: { [weak self] (animation) in
                        guard let self = self else {return}
                        self.animationView.animation = animation
                        self.animationView.play()
                        }, animationCache: LRUAnimationCache.sharedCache)
                } else {
                    displayDelegate.configureMediaMessageImageView(imageView, for: message, at: indexPath, in: messagesCollectionView)
                }
            }
            playButtonView.isHidden = true
        default:
            break
        }        
    }
    
    func setupViewBodySticker() {
        animationView.loopMode = .loop
        messageContainerView.addSubview(animationView)
        animationView.fillSuperview()
    }
}
