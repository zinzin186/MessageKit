//
//  ActionMessageSizeCalculator.swift
//  MessageKit
//
//  Created by Gapo on 10/7/20.
//

import Foundation
import UIKit

open class ActionMessageSizeCalculator: MessageSizeCalculator {

   

    public var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)

    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        let messageSize = messageContainerSize(for: message, indexPath: indexPath)
        return CGSize(width: messageSize.width, height: messageSize.height)
    }
    
    
    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        let maxWidth = messagesLayout.itemWidth - 30//messageContainerMaxWidth(for: message)
        switch message.kind {
        case .action(let text):
            let attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: messageLabelFont])
            let messageContainerSize = labelSize(for: attributedText, considering: maxWidth)
            return messageContainerSize
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }

}

