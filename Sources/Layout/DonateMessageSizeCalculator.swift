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
        if case MKActionType.remove = message.action {
            return CGSize.zero
        }
        let contentTextSize = super.messageContainerSize(for: message, indexPath: indexPath)
        let padding: CGFloat = 2
        let maxWidth = messageContainerMaxWidth(for: message)
        
        if case MKMessageKind.donate(let donateInfo, _) = message.kind {
            guard let displayDelegate = messagesLayout.messagesCollectionView.messagesDisplayDelegate else {
                fatalError(MessageKitError.nilMessagesDisplayDelegate)
            }
            let donateAttributes = displayDelegate.donateTextAttributes(at: indexPath, in: messagesLayout.messagesCollectionView)
            let attributedText = NSAttributedString(string: donateInfo, attributes: donateAttributes)
            var donateInfoSize = MessageSizeCalculator.labelSize(for: attributedText, considering: maxWidth)
            let contentInset: UIEdgeInsets = MKMessageConstant.ContentInsets.donate
            let coinIconSize: CGSize = MKMessageConstant.Sizes.Donate.iconCoin
            donateInfoSize.width += (contentInset.left + 4 + coinIconSize.width + contentInset.right)
            donateInfoSize.height += (contentInset.top + contentInset.bottom)
            if donateInfoSize.height < MKMessageConstant.Sizes.Donate.donateInfoHeight {
                donateInfoSize.height = MKMessageConstant.Sizes.Donate.donateInfoHeight
            }
            let heightOfContainer: CGFloat = donateInfoSize.height + contentTextSize.height + padding
            let widthOfContainer: CGFloat = max(donateInfoSize.width, contentTextSize.width)
            return CGSize(width: widthOfContainer, height: heightOfContainer)
        }
        
        

        return CGSize.zero
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
