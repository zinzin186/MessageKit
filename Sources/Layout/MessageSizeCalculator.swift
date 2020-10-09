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

open class MessageSizeCalculator: CellSizeCalculator {

    public init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }

    public var incomingAvatarSize = CGSize(width: 30, height: 30)
    public var outgoingAvatarSize = CGSize(width: 30, height: 30)
    
    public var messageLabelFont =  UIFont.preferredFont(forTextStyle: .body)

    public var incomingAvatarPosition = AvatarPosition(vertical: .cellBottom)
    public var outgoingAvatarPosition = AvatarPosition(vertical: .cellBottom)

    public var avatarLeadingTrailingPadding: CGFloat = 0

    public var incomingMessagePadding = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
    public var outgoingMessagePadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)

    public var incomingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    public var outgoingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    
    public var incomingCellBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 42))
    public var outgoingCellBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 42))

    public var incomingMessageTopLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 42))
    public var outgoingMessageTopLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 42))

    public var incomingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 42))
    public var outgoingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 42))

    public var incomingAccessoryViewSize = CGSize.zero
    public var outgoingAccessoryViewSize = CGSize.zero

    public var incomingAccessoryViewPadding = HorizontalEdgeInsets.zero
    public var outgoingAccessoryViewPadding = HorizontalEdgeInsets.zero
    
    public var incomingAccessoryViewPosition: AccessoryPosition = .messageCenter
    public var outgoingAccessoryViewPosition: AccessoryPosition = .messageCenter

    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.avatarSize = avatarSize(for: message)
        attributes.avatarPosition = avatarPosition(for: message)
        attributes.avatarLeadingTrailingPadding = avatarLeadingTrailingPadding

        attributes.actionBodyPadding = replyBodyPadding(for: message)
        attributes.messageContainerPadding = messageContainerPadding(for: message)
        attributes.actionBodySize = replyBodySize(for: message)
        attributes.messageContainerSize = messageContainerSize(for: message, indexPath: indexPath)
        attributes.cellTopLabelSize = cellTopLabelSize(for: message, at: indexPath)
        attributes.cellTopLabelAlignment = cellTopLabelAlignment(for: message)
        attributes.cellBottomLabelSize = cellBottomLabelSize(for: message, at: indexPath)
        attributes.messageTimeLabelSize = messageTimeLabelSize(for: message, at: indexPath)
        attributes.cellBottomLabelAlignment = cellBottomLabelAlignment(for: message)
        attributes.messageTopLabelSize = messageTopLabelSize(for: message, at: indexPath)
        attributes.messageTopLabelAlignment = messageTopLabelAlignment(for: message)

        attributes.messageBottomLabelAlignment = messageBottomLabelAlignment(for: message)
        attributes.messageBottomLabelSize = messageBottomLabelSize(for: message, at: indexPath)

        attributes.accessoryViewSize = accessoryViewSize(for: message)
        attributes.accessoryViewPadding = accessoryViewPadding(for: message)
        attributes.accessoryViewPosition = accessoryViewPosition(for: message)
        attributes.iconMarkReplySize = iconMarkReplySize(for: message)
        attributes.messageLabelFont = messageLabelFont
    }

    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        let itemHeight = cellContentHeight(for: message, at: indexPath)
        return CGSize(width: messagesLayout.itemWidth, height: itemHeight)
    }

    open func cellContentHeight(for message: MKMessageType, at indexPath: IndexPath) -> CGFloat {

        let replyBodyHeight = replyBodySize(for: message).height
        let messageContainerHeight = messageContainerSize(for: message, indexPath: indexPath).height
        let cellBottomLabelHeight = cellBottomLabelSize(for: message, at: indexPath).height
        let messageBottomLabelHeight = messageBottomLabelSize(for: message, at: indexPath).height
        let cellTopLabelHeight = cellTopLabelSize(for: message, at: indexPath).height
        let messageTopLabelHeight = messageTopLabelSize(for: message, at: indexPath).height
        let messageVerticalPadding = messageContainerPadding(for: message).vertical
        let avatarHeight = avatarSize(for: message).height
        let avatarVerticalPosition = avatarPosition(for: message).vertical
        let accessoryViewHeight = accessoryViewSize(for: message).height

        var paddingContainerViewWithReplyBody: CGFloat = replyBodyHeight > 0 ? 20 : 0
        if case ActionType.remove = message.action{
            paddingContainerViewWithReplyBody = 0
        }
        
        switch avatarVerticalPosition {
        case .messageCenter:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight + replyBodyHeight
                + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight - paddingContainerViewWithReplyBody
            let cellHeight = max(avatarHeight, totalLabelHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageBottom:
            var cellHeight: CGFloat = 0
            cellHeight += messageBottomLabelHeight
            cellHeight += cellBottomLabelHeight
            let labelsHeight = replyBodyHeight + messageContainerHeight - paddingContainerViewWithReplyBody + messageVerticalPadding + cellTopLabelHeight + messageTopLabelHeight
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            cellHeight += messageTopLabelHeight
            let labelsHeight = replyBodyHeight + messageContainerHeight - paddingContainerViewWithReplyBody + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageLabelTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            let messageLabelsHeight = replyBodyHeight + messageContainerHeight - paddingContainerViewWithReplyBody + messageBottomLabelHeight + messageVerticalPadding + messageTopLabelHeight + cellBottomLabelHeight
            cellHeight += max(messageLabelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .cellTop, .cellBottom:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight - paddingContainerViewWithReplyBody + replyBodyHeight
                + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
            let cellHeight = max(avatarHeight, totalLabelHeight)
            return max(cellHeight, accessoryViewHeight)
        }
    }

    // MARK: - Avatar

    open func avatarPosition(for message: MKMessageType) -> AvatarPosition {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        var position = isFromCurrentSender ? outgoingAvatarPosition : incomingAvatarPosition

        switch position.horizontal {
        case .cellTrailing, .cellLeading:
            break
        case .natural:
            position.horizontal = isFromCurrentSender ? .cellTrailing : .cellLeading
        }
        return position
    }

    open func avatarSize(for message: MKMessageType) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAvatarSize : incomingAvatarSize
    }

    // MARK: - Top cell Label

    open func cellTopLabelSize(for message: MKMessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.cellTopLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }

    open func cellTopLabelAlignment(for message: MKMessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingCellTopLabelAlignment : incomingCellTopLabelAlignment
    }
    
    // MARK: - Top message Label
    
    open func messageTopLabelSize(for message: MKMessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.messageTopLabelHeight(for: message, at: indexPath, in: collectionView)
//        return CGSize(width: messagesLayout.itemWidth, height: height)
        let dataSource = messagesLayout.messagesDataSource
        if let attributedText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath){
            let topLabelWidth = labelWidth(for: attributedText, considering: height)
            return CGSize(width: topLabelWidth, height: height)
        }else{
            return CGSize.zero
        }
        
        
    }
    
    open func messageTopLabelAlignment(for message: MKMessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageTopLabelAlignment : incomingMessageTopLabelAlignment
    }

    // MARK: - Message time label

    open func messageTimeLabelSize(for message: MKMessageType, at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        guard let attributedText = dataSource.messageTimestampLabelAttributedText(for: message, at: indexPath) else {
            return .zero
        }
        let size = attributedText.size()
        return CGSize(width: size.width, height: size.height)
    }

    // MARK: - Bottom cell Label
    
    open func cellBottomLabelSize(for message: MKMessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.cellBottomLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }
    
    open func cellBottomLabelAlignment(for message: MKMessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingCellBottomLabelAlignment : incomingCellBottomLabelAlignment
    }

    // MARK: - Bottom Message Label

    open func messageBottomLabelSize(for message: MKMessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.messageBottomLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }

    open func messageBottomLabelAlignment(for message: MKMessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageBottomLabelAlignment : incomingMessageBottomLabelAlignment
    }

    // MARK: - Accessory View

    public func accessoryViewSize(for message: MKMessageType) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAccessoryViewSize : incomingAccessoryViewSize
    }

    public func accessoryViewPadding(for message: MKMessageType) -> HorizontalEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAccessoryViewPadding : incomingAccessoryViewPadding
    }
    
    public func accessoryViewPosition(for message: MKMessageType) -> AccessoryPosition {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAccessoryViewPosition : incomingAccessoryViewPosition
    }

    // MARK: - MessageContainer
    
    open func replyBodyPadding(for message: MKMessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessagePadding : incomingMessagePadding
    }

    open func messageContainerPadding(for message: MKMessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessagePadding : incomingMessagePadding
    }
    
    open func replyBodySize(for message: MKMessageType) -> CGSize {
        // Returns .zero by default
        switch message.action {
        case .reply(let replyMessage):
            let maxWidth = messageContainerMaxWidth(for: message)

            var actionContainerSize: CGSize
            let attributedText: NSAttributedString

            switch replyMessage.kind {
            case .attributedText(let text):
                attributedText = text
            case .text(let text), .emoji(let text):
                attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 13)])
            default:
                return CGSize(width: 120, height: 80)
            }

            actionContainerSize = labelSize(for: attributedText, considering: maxWidth)
            actionContainerSize.width += 10
            actionContainerSize.height += 30
            return actionContainerSize
        case .remove:
            let contentText: String
            if case MessageKind.text(let text) = message.kind {
                contentText = text
            }else {
                contentText = "Tin nhắn đã bị xoá"
            }
            let attributedText: NSAttributedString = NSAttributedString(string: contentText, attributes: [.font: UIFont.italicSystemFont(ofSize: 13)])
            var actionContainerSize: CGSize
            let maxWidth = messageContainerMaxWidth(for: message)
            actionContainerSize = labelSize(for: attributedText, considering: maxWidth)
            actionContainerSize.width += 10
            actionContainerSize.height += 10
            return actionContainerSize
        default:
            return CGSize.zero
        }
        
    }

    open func iconMarkReplySize(for message: MKMessageType) -> CGSize {
        switch message.action {
        case .reply:
            return CGSize(width: 15, height: 15)
        default:
            return CGSize.zero
        }
    }
    
    open func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        // Returns .zero by default
        return .zero
    }

    open func messageContainerMaxWidth(for message: MKMessageType) -> CGFloat {
        let avatarWidth = avatarSize(for: message).width
        let messagePadding = messageContainerPadding(for: message)
        let accessoryWidth = accessoryViewSize(for: message).width
        let accessoryPadding = accessoryViewPadding(for: message)
        return messagesLayout.itemWidth - avatarWidth - messagePadding.horizontal - accessoryWidth - accessoryPadding.horizontal - avatarLeadingTrailingPadding
    }

    // MARK: - Helpers

    public var messagesLayout: MessagesCollectionViewFlowLayout {
        guard let layout = layout as? MessagesCollectionViewFlowLayout else {
            fatalError("Layout object is missing or is not a MessagesCollectionViewFlowLayout")
        }
        return layout
    }

    internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
    internal func labelWidth(for attributedText: NSAttributedString, considering maxHeight: CGFloat) -> CGFloat {
        let constraintBox = CGSize(width: .greatestFiniteMagnitude, height: maxHeight)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size.width
    }
}

fileprivate extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}
