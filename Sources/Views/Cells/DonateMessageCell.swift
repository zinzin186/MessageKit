//
//  DonateMessageCell.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/11/20.
//

import UIKit

class DonateMessageCell: TextMessageCell {
    
    lazy var donateView: DonateView = {
        let view = DonateView()
        return view
    }()

    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(donateView)
    }
    
    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .donate(contentString) = message.kind else { fatalError("Failed decorate donate cell") }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
        let textFont = displayDelegate.textFont(for: message, at: indexPath, in: messagesCollectionView)
        donateView.frame = messageContainerView.bounds
        donateView.lblAmountCoin.text = contentString
        donateView.lblAmountCoin.textColor = textColor
        donateView.lblAmountCoin.font = textFont
                
    }

}

