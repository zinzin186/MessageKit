//
//  ActionMessageSizeCalculator.swift
//  MessageKit
//
//  Created by Gapo on 10/7/20.
//

import Foundation
import UIKit

open class ActionMessageSizeCalculator: MessageSizeCalculator {

    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        let cellTopLabelHeight = cellTopLabelSize(for: message, at: indexPath).height
        let messageActionSize = messageContainerSize(for: message, indexPath: indexPath)
        return CGSize(width: messageActionSize.width, height: messageActionSize.height + cellTopLabelHeight)
    }
    
    
    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        let maxWidth = messagesLayout.itemWidth - 60//messageContainerMaxWidth(for: message)
        switch message.kind {
        case .action(let text):
            let displayDelegate = messagesLayout.messagesCollectionView.messagesDisplayDelegate
            let attributedText = NSAttributedString(string: text, attributes: displayDelegate?.configureTextForActionMessage(at: indexPath, in: messagesLayout.messagesCollectionView))
            let contentInset = MKMessageConstant.ActionNote.contentInset
            let messageContainerHeight = MessageSizeCalculator.labelSize(for: attributedText, considering: maxWidth).height + contentInset.top + contentInset.bottom
//            if messageContainerHeight < MKMessageConstant.Limit.minContainerBodyHeight {
//                messageContainerHeight = MKMessageConstant.Limit.minContainerBodyHeight
//            }
            return CGSize(width: maxWidth, height: messageContainerHeight)
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }

}

