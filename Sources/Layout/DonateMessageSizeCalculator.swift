//
//  DonateMessageSizeCalculator.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/11/20.
//

import Foundation
import UIKit

open class DonateMessageSizeCalculator: TextMessageSizeCalculator {

    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        if case ActionType.remove = message.action {
            return CGSize.zero
        }
        let maxWidth = messageContainerMaxWidth(for: message)
        var messageContainerSize: CGSize
        let attributedText = self.genAttributeMessage(with: message, at: indexPath)
        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)

//        let messageInsets = messageLabelInsets(for: message)
        let iconCoinSize: CGSize = CGSize(width: 16, height: 16)
        messageContainerSize.width += (24 + iconCoinSize.width + 5)
        messageContainerSize.height += 14

        return messageContainerSize
    }

    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.messageLabelInsets = messageLabelInsets(for: message)
    }
    
}
