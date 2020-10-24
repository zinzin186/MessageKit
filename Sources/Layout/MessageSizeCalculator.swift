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
    
    public var linkPreviewFonts = LinkPreviewFonts(titleFont: .preferredFont(forTextStyle: .footnote),
                                                   teaserFont: .preferredFont(forTextStyle: .caption2),
                                                   domainFont: .preferredFont(forTextStyle: .caption1))

    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.avatarSize = avatarSize(for: message)
        attributes.avatarPosition = avatarPosition(for: message)
        attributes.avatarLeadingTrailingPadding = avatarLeadingTrailingPadding
        attributes.paddingContainerViewWithActionBody = paddingContainerViewWithActionBody(for: message)

        attributes.actionBodyPadding = replyBodyPadding(for: message)
        attributes.messageContainerPadding = messageContainerPadding(for: message)
        attributes.actionBodySize = actionBodySize(for: message, indexPath: indexPath)
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
        attributes.linkPreviewFonts = linkPreviewFonts
    }

    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        let itemHeight = cellContentHeight(for: message, at: indexPath)
        return CGSize(width: messagesLayout.itemWidth, height: itemHeight)
    }

    open func cellContentHeight(for message: MKMessageType, at indexPath: IndexPath) -> CGFloat {

        let actionBodyHeight = actionBodySize(for: message, indexPath: indexPath).height
        let messageContainerHeight = messageContainerSize(for: message, indexPath: indexPath).height
        let cellBottomLabelHeight = cellBottomLabelSize(for: message, at: indexPath).height
        let messageBottomLabelHeight = messageBottomLabelSize(for: message, at: indexPath).height
        let cellTopLabelHeight = cellTopLabelSize(for: message, at: indexPath).height
        let messageTopLabelHeight = messageTopLabelSize(for: message, at: indexPath).height
        let messageVerticalPadding = messageContainerPadding(for: message).vertical
        let avatarHeight = avatarSize(for: message).height
        let avatarVerticalPosition = avatarPosition(for: message).vertical
        let accessoryViewHeight = accessoryViewSize(for: message).height
        let paddingContainerViewToActionBody = paddingContainerViewWithActionBody(for: message)
        let messageBodyHeight = actionBodyHeight + paddingContainerViewToActionBody + messageContainerHeight
        
        switch avatarVerticalPosition {
        case .messageCenter:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight + messageBodyHeight + messageBottomLabelHeight + cellBottomLabelHeight + messageVerticalPadding
            let cellHeight = max(avatarHeight, totalLabelHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageBottom:
            var cellHeight: CGFloat = 0
            cellHeight += messageBottomLabelHeight
            cellHeight += cellBottomLabelHeight
            let labelsHeight = messageBodyHeight + messageVerticalPadding + cellTopLabelHeight + messageTopLabelHeight
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            cellHeight += messageTopLabelHeight
            let labelsHeight = messageBodyHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .messageLabelTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            let messageLabelsHeight = messageBodyHeight + messageBottomLabelHeight + messageVerticalPadding + messageTopLabelHeight + cellBottomLabelHeight
            cellHeight += max(messageLabelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight)
        case .cellTop, .cellBottom:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight + messageBodyHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
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

    open func paddingContainerViewWithActionBody(for message: MKMessageType) -> CGFloat {
        switch message.action {
        case .reply:
            return MKMessageConstant.ActionView.ReplyView.bottomPadding
        case .story:
            return MKMessageConstant.ActionView.StoryView.bottomPadding
        default:
            return 0
        }
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
    
    open func actionBodySize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        // Returns .zero by default
        let dataSource = messagesLayout.messagesDataSource
        let attributedText: NSAttributedString = dataSource.messageActionLabelAttributedText(for: message.action, at: indexPath) ?? NSAttributedString(string: "")
        let maxWidth = messageContainerMaxWidth(for: message)
        var actionContainerSize: CGSize
        actionContainerSize = labelSize(for: attributedText, considering: maxWidth)
        if actionContainerSize.height > MKMessageConstant.Limit.maxActionReplyTextHeight {
            actionContainerSize.height = MKMessageConstant.Limit.maxActionReplyTextHeight
        }
        let contentInset = MKMessageConstant.ActionView.ReplyView.contentTextInset
        actionContainerSize.width += (contentInset.left + contentInset.right)
        actionContainerSize.height += (contentInset.top + contentInset.bottom)
        switch message.action {
        case .reply(let replyMessage):
            if let medias = replyMessage.medias, medias.count > 0, !replyMessage.deleted{
                var contentSize: CGSize = .zero
                if let attributedString = dataSource.messageActionLabelAttributedText(for: message.action, at: indexPath) {
                    contentSize = self.labelSize(for: attributedString, considering: 120)
                }
                return self.getSizeOfReplyMedia(contentSize: contentSize)
            }
            let bottomPadding = MKMessageConstant.ActionView.ReplyView.bottomPadding < 0 ? -MKMessageConstant.ActionView.ReplyView.bottomPadding : 0
            actionContainerSize.height += bottomPadding
            return actionContainerSize
        case .remove:
            let bottomPadding = MKMessageConstant.ActionView.RemoveView.bottomPadding < 0 ? -MKMessageConstant.ActionView.ReplyView.bottomPadding : 0
            actionContainerSize.height += bottomPadding
            return actionContainerSize
        case .story:
            return MKMessageConstant.ActionView.StoryView.mediaSize
        case .default:
            return CGSize.zero
        }
        
    }

    private func getSizeOfReplyMedia(contentSize: CGSize) -> CGSize {
        let contentOffset = MKMessageConstant.ActionView.ReplyView.contentMediaInset
        let heightOfImage: CGFloat = MKMessageConstant.ActionView.ReplyView.mediaSize.height
        let widthOfImage: CGFloat = MKMessageConstant.ActionView.ReplyView.mediaSize.width
        let padding: CGFloat = MKMessageConstant.ActionView.ReplyView.bottomPadding
        let height: CGFloat = contentOffset.top + heightOfImage + contentOffset.bottom - padding
        return CGSize(width: contentOffset.horizontal + widthOfImage + 5 + contentSize.width, height: height + 90)
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
