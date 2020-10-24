/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import UIKit

open class TextMessageSizeCalculator: MessageSizeCalculator {

    internal func messageLabelInsets(for message: MKMessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? MKMessageConstant.ContentInsets.Text.outgoingMessageLabelInsets : MKMessageConstant.ContentInsets.Text.incomingMessageLabelInsets
    }

    open override func messageContainerMaxWidth(for message: MKMessageType) -> CGFloat {
        let maxWidth = super.messageContainerMaxWidth(for: message)
        let textInsets = messageLabelInsets(for: message)
        return maxWidth - textInsets.horizontal
    }
    
    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        if case MKActionType.remove = message.action {
            return CGSize.zero
        }
        let maxWidth = messageContainerMaxWidth(for: message)
        var messageContainerSize: CGSize
        let attributedText = self.genAttributeMessage(with: message, at: indexPath)
        if attributedText.string.isEmpty {
            return CGSize.zero
        }
        messageContainerSize = labelSize(for: attributedText, considering: maxWidth)

        let messageInsets = messageLabelInsets(for: message)
        messageContainerSize.width += messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical
        if messageContainerSize.height < MKMessageConstant.Limit.minContainerBodyHeight{
            messageContainerSize.height = MKMessageConstant.Limit.minContainerBodyHeight
        }
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
    
    internal func genAttributeMessage(with message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString {
        guard let displayDelegate = messagesLayout.messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        let attributedString: NSMutableAttributedString
        switch message.kind {
        case .text(let text), .emoji(let text):
            let attributes = displayDelegate.textAttributes(for: message, at: indexPath, in: messagesLayout.messagesCollectionView)
            attributedString = NSMutableAttributedString(string: text, attributes: attributes)
        case .donate( _, let text):
            let attributes = displayDelegate.textAttributes(for: message, at: indexPath, in: messagesLayout.messagesCollectionView)
            attributedString = NSMutableAttributedString(string: text ?? "", attributes: attributes)
        case .attributedText(let text):
            attributedString = NSMutableAttributedString(attributedString: text)
        case .linkPreview(let linkItem):
            let attributes = displayDelegate.textAttributes(for: message, at: indexPath, in: messagesLayout.messagesCollectionView)
            attributedString = NSMutableAttributedString(string: linkItem.text, attributes: attributes)
        default:
            attributedString = NSMutableAttributedString(string: "")
        }
        
        let enabledDetectors = displayDelegate.enabledDetectors(for: message, at: indexPath, in: messagesLayout.messagesCollectionView)
        for detector in enabledDetectors {
            switch detector {
            case .mentionRange(let mentionInfo):
                let attributes = displayDelegate.detectorAttributes(for: detector, and: message, at: indexPath)
                mentionInfo.forEach({attributedString.addAttributes(attributes, range: $0.range)})
            default:
                break
            }
        }
        let modifiedText = NSAttributedString(attributedString: attributedString)
        return modifiedText
    }
}
