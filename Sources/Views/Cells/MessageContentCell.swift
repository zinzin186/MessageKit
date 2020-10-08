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

/// A subclass of `MessageCollectionViewCell` used to display text, media, and location messages.
open class MessageContentCell: MessageCollectionViewCell, UIGestureRecognizerDelegate {

    /// The image view displaying the avatar.
    open var avatarView = AvatarView()
    
    open var sendStatusImageView = UIImageView()

    /// The container used for styling and holding the message's content view.
    lazy var replyBodyView: ReplyBodyView = {
        let replyView = ReplyBodyView()
        replyView.backgroundColor = UIColor.groupTableViewBackground
        replyView.clipsToBounds = true
        replyView.layer.cornerRadius = 10
        return replyView
    }()
    
    
    open var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    open var iconReply: UIImageView = {
        let imgvCanReply = UIImageView()
        imgvCanReply.image = UIImage(named: "mk_icon_chat_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        imgvCanReply.contentMode = .scaleAspectFit
        return imgvCanReply
    }()
    
    lazy var iconMarkReply: UIImageView = {
        let imgvReply = UIImageView()
        imgvReply.image = UIImage(named: "mk_icon_mark_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        imgvReply.clipsToBounds = true
        imgvReply.isHidden = true
        imgvReply.contentMode = .scaleAspectFill
        return imgvReply
    }()

    /// The top label of the cell.
    open var cellTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// The bottom label of the cell.
    open var cellBottomLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    /// The top label of the messageBubble.
    open var messageTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()

    /// The bottom label of the messageBubble.
    open var messageBottomLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        return label
    }()

    /// The time label of the messageBubble.
//    open var messageTimestampLabel: InsetLabel = InsetLabel()

    // Should only add customized subviews - don't change accessoryView itself.
    open var accessoryView: UIView = UIView()

    /// The `MessageCellDelegate` for the cell.
    open weak var delegate: MKMessageCellDelegate?
    var panGesture = UIPanGestureRecognizer()
    var shouldReply: Bool = false
    

    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        setupSubviews()
    }
    
    open func setupSubviews() {
        contentView.addSubview(accessoryView)
        contentView.addSubview(cellTopLabel)
        contentView.addSubview(messageTopLabel)
        contentView.addSubview(iconMarkReply)
        contentView.addSubview(messageBottomLabel)
        contentView.addSubview(cellBottomLabel)
        contentView.addSubview(replyBodyView)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(avatarView)
        contentView.addSubview(sendStatusImageView)
        setupViewContainter()
    }
    
    func setupViewContainter() {
        contentView.addSubview(iconReply)
        contentView.backgroundColor = .clear
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(actionDrag(_:)))
        panGesture.delegate = self
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(panGesture)
    }
    
    func layoutImageCanReply() {
        let iconReplySize: CGSize = CGSize(width: 24, height: 24)
        let originX: CGFloat = contentView.frame.size.width + 24
        let originY: CGFloat = messageContainerView.frame.midY - iconReplySize.height/2
        iconReply.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: iconReplySize)
    }
    
    @objc func actionDrag(_ sender:UIPanGestureRecognizer) {
        let translation: CGPoint = sender.translation(in: self.superview)
        let center: CGPoint = contentView.center
        var newX: CGFloat = center.x + translation.x
        if newX <= contentView.frame.size.width/2 {
            // Vượt quá breakX sẽ là action reply
            let breakX = frame.width/2 - CGFloat(60)
            newX = max(breakX, newX)
            let newY: CGFloat = center.y
            contentView.center = CGPoint(x: newX, y: newY)
            sender.setTranslation(CGPoint.zero, in: self.superview)
            if sender.state == UIGestureRecognizer.State.changed {
                if shouldReply {
                    if newX > breakX {
                        shouldReply = false
                    }
                } else {
                    if newX <= breakX {
                        delegate?.cellShouldReplyMessage(cell: self)
                        shouldReply = true
                    }
                }
            }
        }
        
        if sender.state == UIGestureRecognizer.State.ended {
            if shouldReply{
                shouldReply = false
                delegate?.cellDidRequestReplyMessage(cell: self)
            }
            contentView.center = CGPoint(x: contentView.frame.size.width/2, y: contentView.frame.size.height/2)
        }
    }
    open override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        cellBottomLabel.text = nil
        messageTopLabel.text = nil
        iconMarkReply.isHidden = true
        messageBottomLabel.text = nil
//        messageTimestampLabel.attributedText = nil
    }

    // MARK: - Configuration

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        // Call this before other laying out other subviews
        layoutReplyView(with: attributes)
        layoutMessageContainerView(with: attributes)
        layoutMessageBottomLabel(with: attributes)
        layoutCellBottomLabel(with: attributes)
        layoutCellTopLabel(with: attributes)
        layoutMessageTopLabel(with: attributes)
        layoutAvatarView(with: attributes)
        layoutSendStatusView(with: attributes)
        layoutAccessoryView(with: attributes)
        layoutImageCanReply()
    }

    /// Used to configure the cell.
    ///
    /// - Parameters:
    ///   - message: The `MessageType` this cell displays.
    ///   - indexPath: The `IndexPath` for this cell.
    ///   - messagesCollectionView: The `MessagesCollectionView` in which this cell is contained.
    open func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        delegate = messagesCollectionView.messageCellDelegate

        let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
        let messageStyle = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)

        displayDelegate.configureAvatarView(avatarView, for: message, at: indexPath, in: messagesCollectionView)
        
        displayDelegate.configureSendStatusView(sendStatusImageView, for: message, at: indexPath, in: messagesCollectionView)

        displayDelegate.configureAccessoryView(accessoryView, for: message, at: indexPath, in: messagesCollectionView)

        messageContainerView.backgroundColor = messageColor
        messageContainerView.style = messageStyle

//        let topCellLabelText = dataSource.cellTopLabelAttributedText(for: message, at: indexPath)
        let bottomCellLabelText = dataSource.cellBottomLabelAttributedText(for: message, at: indexPath)
        let topMessageLabelText = dataSource.messageTopLabelAttributedText(for: message, at: indexPath)
        let bottomMessageLabelText = dataSource.messageBottomLabelAttributedText(for: message, at: indexPath)
        let messageTimestampLabelText = dataSource.messageTimestampLabelAttributedText(for: message, at: indexPath)
        cellTopLabel.attributedText = messageTimestampLabelText
        cellBottomLabel.attributedText = bottomCellLabelText
        messageTopLabel.attributedText = topMessageLabelText
        messageBottomLabel.attributedText = bottomMessageLabelText
//        messageTimestampLabel.attributedText = messageTimestampLabelText
        let isOutgoingMessage = dataSource.isFromCurrentSender(message: message)
        replyBodyView.applyUI(isOutgoingMessage: isOutgoingMessage, message: message)
        
        if case ActionType.reply(let replyMessage) = message.action {
            self.iconMarkReply.isHidden = false
            displayDelegate.configureReplyMediaMessageImageView(replyBodyView.imageView, for: replyMessage, at: indexPath, in: messagesCollectionView)
        }else{
            self.iconMarkReply.isHidden = true
        }
    }

    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)

        switch true {
        case messageContainerView.frame.contains(touchLocation) && !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
            delegate?.didTapMessage(in: self)
        case avatarView.frame.contains(touchLocation):
            delegate?.didTapAvatar(in: self)
        case cellTopLabel.frame.contains(touchLocation):
            delegate?.didTapCellTopLabel(in: self)
        case cellBottomLabel.frame.contains(touchLocation):
            delegate?.didTapCellBottomLabel(in: self)
        case messageTopLabel.frame.contains(touchLocation):
            delegate?.didTapMessageTopLabel(in: self)
        case messageBottomLabel.frame.contains(touchLocation):
            delegate?.didTapMessageBottomLabel(in: self)
        case accessoryView.frame.contains(touchLocation):
            delegate?.didTapAccessoryView(in: self)
        default:
            delegate?.didTapBackground(in: self)
        }
    }

    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            let velocity = panGesture.velocity(in: contentView)
            if velocity.x < 0 {
                if abs(velocity.y) > abs(velocity.x) {
                    return false
                } else {
                    return true
                }
            } else {
                return false
            }
        }
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self){
            let touchPoint = gestureRecognizer.location(in: self)
            return messageContainerView.frame.contains(touchPoint)
        }
        return true
    }
    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    open func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return false
    }

    // MARK: - Origin Calculations

    /// Positions the cell's `AvatarView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutAvatarView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let padding = attributes.avatarLeadingTrailingPadding

        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = padding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - padding
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        switch attributes.avatarPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.minY
        case .messageBottom: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.maxY - attributes.avatarSize.height
        case .messageCenter: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.midY - (attributes.avatarSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.avatarSize.height
        default:
            break
        }
        avatarView.frame = CGRect(origin: origin, size: attributes.avatarSize)
    }

    open func layoutSendStatusView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let padding = attributes.sendStatusLeadingTrailingPadding

        origin.x = attributes.frame.width - attributes.sendStatusSize.width - padding

        switch attributes.sendStatusPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.minY
        case .messageBottom: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.maxY - attributes.sendStatusSize.height
        case .messageCenter: // Needs messageContainerView frame to be set
            origin.y = messageContainerView.frame.midY - (attributes.sendStatusSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.sendStatusSize.height
        default:
            break
        }
        sendStatusImageView.frame = CGRect(origin: origin, size: attributes.sendStatusSize)
    }
    
    open func layoutReplyView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        
        let paddingMessageContainerViewWith: CGFloat = attributes.replyBodySize == CGSize.zero ? 0 : 20

        switch attributes.avatarPosition.vertical {
        case .messageBottom:
            origin.y = attributes.size.height - attributes.replyBodyPadding.bottom - attributes.cellBottomLabelSize.height - attributes.messageBottomLabelSize.height - attributes.replyBodySize.height - attributes.replyBodyPadding.top - attributes.messageContainerSize.height + paddingMessageContainerViewWith
        case .messageCenter:
            if attributes.avatarSize.height > attributes.replyBodySize.height {
                let messageHeight = attributes.replyBodySize.height + attributes.replyBodyPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                fallthrough
            }
        default:
            origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.replyBodyPadding.top
        }

        let avatarPadding = attributes.avatarLeadingTrailingPadding
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = attributes.avatarSize.width + attributes.replyBodyPadding.left + avatarPadding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.sendStatusSize.width - attributes.replyBodySize.width - attributes.replyBodyPadding.right - avatarPadding
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        replyBodyView.frame = CGRect(origin: origin, size: attributes.replyBodySize)
    }
    
    /// Positions the cell's `MessageContainerView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let paddingMessageContainerViewWith: CGFloat = attributes.replyBodySize == CGSize.zero ? 0 : 20
        switch attributes.avatarPosition.vertical {
        case .messageBottom:
            origin.y = attributes.size.height - attributes.messageContainerPadding.bottom - attributes.cellBottomLabelSize.height - attributes.messageBottomLabelSize.height - attributes.messageContainerSize.height - attributes.messageContainerPadding.top
        case .messageCenter:
            if attributes.avatarSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height + attributes.messageContainerPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                fallthrough
            }
        default:
            if attributes.accessoryViewSize.height > attributes.messageContainerSize.height {
                let messageHeight = attributes.messageContainerSize.height + attributes.messageContainerPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.messageContainerPadding.top + attributes.replyBodySize.height - paddingMessageContainerViewWith
            }
        }

        let avatarPadding = attributes.avatarLeadingTrailingPadding
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = attributes.avatarSize.width + attributes.messageContainerPadding.left + avatarPadding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.sendStatusSize.width - attributes.messageContainerSize.width - attributes.messageContainerPadding.right - avatarPadding
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        messageContainerView.frame = CGRect(origin: origin, size: attributes.messageContainerSize)
    }

    /// Positions the cell's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutCellTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        cellTopLabel.textAlignment = attributes.cellTopLabelAlignment.textAlignment
        cellTopLabel.textInsets = attributes.cellTopLabelAlignment.textInsets

        cellTopLabel.frame = CGRect(origin: .zero, size: attributes.cellTopLabelSize)
    }
    
    /// Positions the cell's bottom label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutCellBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        cellBottomLabel.textAlignment = attributes.cellBottomLabelAlignment.textAlignment
        cellBottomLabel.textInsets = attributes.cellBottomLabelAlignment.textInsets
        
        let y = messageBottomLabel.frame.maxY
        let origin = CGPoint(x: 0, y: y)
        
        cellBottomLabel.frame = CGRect(origin: origin, size: attributes.cellBottomLabelSize)
    }
    
    /// Positions the message bubble's top label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageTopLabel.textAlignment = attributes.messageTopLabelAlignment.textAlignment
        
        let textInsets = attributes.messageTopLabelAlignment.textInsets
        
        
        let iconMarkReplySize = attributes.iconMarkReplySize
        let paddingIcon = iconMarkReplySize == .zero ? 0 : iconMarkReplySize.width + 5
        let y = replyBodyView.frame.origin.y - attributes.replyBodyPadding.top - attributes.messageTopLabelSize.height
        let origin = CGPoint(x: 0, y: y)
        let iconX: CGFloat
        messageTopLabel.textInsets = UIEdgeInsets(top: textInsets.top, left: textInsets.left + paddingIcon, bottom: textInsets.bottom, right: textInsets.right)
        if attributes.messageTopLabelAlignment.textAlignment == .left{
            iconX = attributes.messageTopLabelAlignment.textInsets.left
        }else{
            iconX = self.frame.width - attributes.messageTopLabelAlignment.textInsets.right - attributes.messageTopLabelSize.width - paddingIcon
        }
        iconMarkReply.frame = CGRect(x: iconX, y: y + (attributes.messageTopLabelSize.height - iconMarkReplySize.height)/2, width: iconMarkReplySize.width, height: iconMarkReplySize.height)
        messageTopLabel.frame = CGRect(origin: origin, size: CGSize(width: self.frame.width, height: attributes.messageTopLabelSize.height))
    }

    /// Positions the message bubble's bottom label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageBottomLabel.textAlignment = attributes.messageBottomLabelAlignment.textAlignment
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets

        let y = messageContainerView.frame.maxY + attributes.messageContainerPadding.bottom
        let origin = CGPoint(x: 0, y: y)

        messageBottomLabel.frame = CGRect(origin: origin, size: attributes.messageBottomLabelSize)
    }

    /// Positions the cell's accessory view.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutAccessoryView(with attributes: MessagesCollectionViewLayoutAttributes) {
        
        var origin: CGPoint = .zero
        
        // Accessory view is set at the side space of the messageContainerView
        switch attributes.accessoryViewPosition {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop:
            origin.y = messageContainerView.frame.minY
        case .messageBottom:
            origin.y = messageContainerView.frame.maxY - attributes.accessoryViewSize.height
        case .messageCenter:
            origin.y = messageContainerView.frame.midY - (attributes.accessoryViewSize.height / 2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.accessoryViewSize.height
        default:
            break
        }

        // Accessory view is always on the opposite side of avatar
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = messageContainerView.frame.maxX + attributes.accessoryViewPadding.left
        case .cellTrailing:
            origin.x = messageContainerView.frame.minX - attributes.accessoryViewPadding.right - attributes.accessoryViewSize.width
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        accessoryView.frame = CGRect(origin: origin, size: attributes.accessoryViewSize)
    }
    
    open func focusWhenLongPressMessage() {
        let view = messageContainerView
        view.alpha = 0.8
        UIView.animate(withDuration: 0.3 / 1.5, animations: {
            view.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
        }) { _ in
            UIView.animate(withDuration: 0.3 / 2, animations: {
                view.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
            }) { _ in
                UIView.animate(withDuration: 0.3 / 2, animations: {
                    view.transform = CGAffineTransform.identity
                    view.alpha = 1.0
                })
            }
        }
    }
}
