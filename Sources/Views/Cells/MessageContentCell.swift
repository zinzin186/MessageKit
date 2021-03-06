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
    
    /// Ios 14 bi loi hieu ung swipe to reply do su dung contentView nen add boundView de fix.
    public let boundView: UIView = {
        let view = UIView()
        return view
    }()

    /// The container used for styling and holding the message's content view.
    open lazy var actionBodyView: ActionBodyView = {
        let actionView = ActionBodyView()
        actionView.backgroundColor = MKMessageConstant.ActionView.backgroundColor
        actionView.clipsToBounds = true
        actionView.layer.cornerRadius = MKMessageConstant.ActionView.cornerRadius
        actionView.clickReplyMessageCallback = {[unowned self] in
            self.delegate?.didTapActionMessage(in: self)
        }
        return actionView
    }()
    
    open var messageBodyView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    open var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    open var iconReply: UIImageView = {
        let imgvCanReply = UIImageView()
        imgvCanReply.alpha = 0.0
        imgvCanReply.image = MKMessageConstant.Images.replyImage
        imgvCanReply.contentMode = .scaleAspectFit
        return imgvCanReply
    }()
    
    lazy var iconMarkReply: UIImageView = {
        let imgvReply = UIImageView()
        imgvReply.image = MKMessageConstant.Images.markReplyImage
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
    
    public private (set) lazy var longPressGestureRecognizer: UILongPressGestureRecognizer = {
        let longpressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MessageContentCell.messageLongPress(_:)))
        longpressGestureRecognizer.cancelsTouchesInView = true
        longpressGestureRecognizer.delegate = self
        longpressGestureRecognizer.minimumPressDuration = 0.5
        return longpressGestureRecognizer
    }()
    
    
    @objc
    private func messageLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        switch longPressGestureRecognizer.state {
        case .began:
            let touchLocation = longPressGestureRecognizer.location(in: self)
            let messageFrameConvert = convert(messageBodyView.frame, from: boundView)
            switch true {
            case messageFrameConvert.contains(touchLocation):
                self.delegate?.cellDidLongPressMessage(cell: self)
//            case avatarView.frame.contains(touchLocation):
//                self.delegate?.cellDidLongPressAvatar(cell: self)
            default:
                break
            }
//        case .ended, .cancelled:
//            self.onBubbleLongPressEnded?(self)
        default:
            break
        }
    }
    
    
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
        contentView.addSubview(boundView)
        boundView.addSubview(accessoryView)
        boundView.addSubview(cellTopLabel)
        boundView.addSubview(messageTopLabel)
        boundView.addSubview(iconMarkReply)
        boundView.addSubview(messageBottomLabel)
        boundView.addSubview(cellBottomLabel)
        boundView.addSubview(actionBodyView)
        boundView.addSubview(messageBodyView)
        boundView.addSubview(avatarView)
        boundView.addSubview(sendStatusImageView)
        setupViewContainter()
        setupBodyMessageView()
    }
    
    private func setupViewContainter() {
        boundView.addSubview(iconReply)
        boundView.backgroundColor = .clear
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(actionDrag(_:)))
        panGesture.delegate = self
        boundView.isUserInteractionEnabled = true
        boundView.addGestureRecognizer(panGesture)
    }
    
    private func setupBodyMessageView(){
        messageBodyView.addSubview(actionBodyView)
        messageBodyView.addSubview(messageContainerView)
        boundView.addGestureRecognizer(self.longPressGestureRecognizer)
        
    }
    
    @objc func actionDrag(_ sender:UIPanGestureRecognizer) {
        let translation: CGPoint = sender.translation(in: self.superview)
        
        let center: CGPoint = boundView.center
        var newX: CGFloat = center.x + translation.x
        if newX <= boundView.frame.size.width/2 {
            // Vượt quá breakX sẽ là action reply
            let breakX = frame.width/2 - CGFloat(60)
            newX = max(breakX, newX)
            let padding = newX - frame.width/2
            iconReply.alpha =  abs(padding) / 60
            let newY: CGFloat = center.y
            boundView.center = CGPoint(x: newX, y: newY)
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
        }else {
            iconReply.alpha = 1
        }
        
        if sender.state == UIGestureRecognizer.State.ended {
            if shouldReply{
                shouldReply = false
                delegate?.cellDidRequestReplyMessage(cell: self)
            }
            boundView.center = CGPoint(x: boundView.frame.size.width/2, y: boundView.frame.size.height/2)
            iconReply.alpha = 0
        }
    }
    open override func prepareForReuse() {
        super.prepareForReuse()
        cellTopLabel.text = nil
        cellBottomLabel.text = nil
        messageTopLabel.text = nil
        iconMarkReply.isHidden = true
        messageBottomLabel.text = nil
        sendStatusImageView.isHidden = true
//        messageTimestampLabel.attributedText = nil
    }

    // MARK: - Configuration

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        // Call this before other laying out other subviews
        boundView.frame = contentView.bounds
        layoutMessageBodyView(with: attributes)
        layoutActionView(with: attributes)
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
        
        if case MKActionType.remove = message.action {
            iconReply.isHidden = true
        } else {
            iconReply.isHidden = false
        }

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
        actionBodyView.applyUI(isOutgoingMessage: isOutgoingMessage, message: message, attributedText: dataSource.messageActionLabelAttributedText(for: message.action, at: indexPath))
        
        switch message.action {
        case MKActionType.reply:
            self.iconMarkReply.isHidden = false
            if let imageView = actionBodyView.actionReplyMediaView?.imageView{
                displayDelegate.configureActionMessageImageView(imageView, for: message.action, at: indexPath, in: messagesCollectionView)
            }
        case MKActionType.story:
            self.iconMarkReply.isHidden = false
            if let imageView = actionBodyView.actionChatFromStoryView?.imageView{
                displayDelegate.configureActionMessageImageView(imageView, for: message.action, at: indexPath, in: messagesCollectionView)
            }
        default:
            self.iconMarkReply.isHidden = true
        }
        
    }

    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        let messageFrameConvert = convert(messageContainerView.frame, from: messageBodyView)
        switch true {
        case messageFrameConvert.contains(touchLocation):
            if !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)) {
                delegate?.didTapMessage(in: self)
            }
            
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
            guard !iconReply.isHidden else {return false}
            let velocity = panGesture.velocity(in: boundView)
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
        let contentFrame = self.messageBodyView.frame

        switch attributes.avatarPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop: // Needs messageContainerView frame to be set
            origin.y = contentFrame.minY
        case .messageBottom: // Needs messageContainerView frame to be set
            origin.y = contentFrame.maxY - attributes.avatarSize.height
        case .messageCenter: // Needs messageContainerView frame to be set
            origin.y = contentFrame.midY - (attributes.avatarSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.avatarSize.height
        default:
            break
        }
        avatarView.frame = CGRect(origin: origin, size: attributes.avatarSize)
    }
    
    open func layoutMessageBodyView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let messageBodyWidth: CGFloat = max(attributes.messageContainerSize.width, attributes.actionBodySize.width)
//        let messageBodyWidth: CGFloat = max(attributes.messageContainerSize.width + attributes.messageContainerPadding.horizontal, attributes.actionBodySize.width + attributes.actionBodyPadding.horizontal)
        let messageBodyHeight: CGFloat = attributes.messageContainerSize.height + attributes.actionBodySize.height + attributes.paddingContainerViewWithActionBody
        switch attributes.avatarPosition.vertical {
        case .messageBottom:
            origin.y = attributes.size.height - attributes.messageContainerPadding.bottom - attributes.cellBottomLabelSize.height - attributes.messageBottomLabelSize.height - messageBodyHeight - attributes.messageContainerPadding.top
        case .messageCenter:
            if attributes.avatarSize.height > messageBodyHeight {
                let messageHeight = messageBodyHeight + attributes.messageContainerPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                fallthrough
            }
        default:
            if attributes.accessoryViewSize.height > messageBodyHeight {
                let messageHeight = messageBodyHeight + attributes.messageContainerPadding.vertical
                origin.y = (attributes.size.height / 2) - (messageHeight / 2)
            } else {
                origin.y = attributes.cellTopLabelSize.height + attributes.messageTopLabelSize.height + attributes.actionBodyPadding.top
            }
        }

        let avatarPadding = attributes.avatarLeadingTrailingPadding
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = attributes.avatarSize.width + attributes.messageContainerPadding.left + avatarPadding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - attributes.sendStatusSize.width - messageBodyWidth - attributes.messageContainerPadding.right - avatarPadding
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }
        messageBodyView.frame = CGRect(origin: origin, size: CGSize(width: messageBodyWidth, height: messageBodyHeight))
    }

    open func layoutSendStatusView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let padding = attributes.sendStatusLeadingTrailingPadding

        origin.x = attributes.frame.width - attributes.sendStatusSize.width - padding

        switch attributes.sendStatusPosition.vertical {
        case .messageLabelTop:
            origin.y = messageTopLabel.frame.minY
        case .messageTop: // Needs messageContainerView frame to be set
            origin.y = self.messageBodyView.frame.minY
        case .messageBottom: // Needs messageContainerView frame to be set
            origin.y = self.messageBodyView.frame.maxY - attributes.sendStatusSize.height
        case .messageCenter: // Needs messageContainerView frame to be set
            origin.y = self.messageBodyView.frame.midY - (attributes.sendStatusSize.height/2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.sendStatusSize.height
        default:
            break
        }
        sendStatusImageView.frame = CGRect(origin: origin, size: attributes.sendStatusSize)
        sendStatusImageView.layer.cornerRadius = attributes.sendStatusSize.height / 2
        sendStatusImageView.clipsToBounds = true
    }
    
    open func layoutImageCanReply() {
        let iconReplySize: CGSize = CGSize(width: 24, height: 24)
        let originX: CGFloat = contentView.frame.size.width + 24
        let originY: CGFloat = messageBodyView.frame.midY - iconReplySize.height/2
        iconReply.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: iconReplySize)
    }
    
    open func layoutActionView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        origin.y = attributes.actionBodyPadding.top
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = 0
        case .cellTrailing:
            origin.x = self.messageBodyView.frame.width - attributes.actionBodySize.width
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }
        actionBodyView.frame = CGRect(origin: origin, size: attributes.actionBodySize)
    }
    
    /// Positions the cell's `MessageContainerView`.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageContainerView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        origin.y = self.actionBodyView.frame.maxY + attributes.paddingContainerViewWithActionBody
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = 0
        case .cellTrailing:
            origin.x = self.messageBodyView.frame.width - attributes.messageContainerSize.width
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
        let paddingIcon: CGFloat = iconMarkReplySize == .zero ? 0 : iconMarkReplySize.width + MKMessageConstant.ActionView.ReplyView.rightReplyIconPadding
        let y = messageBodyView.frame.origin.y - attributes.actionBodyPadding.top - attributes.messageTopLabelSize.height
        let origin = CGPoint(x: 0, y: y)
        let iconX: CGFloat
        messageTopLabel.textInsets = UIEdgeInsets(top: textInsets.top, left: textInsets.left + paddingIcon, bottom: textInsets.bottom, right: textInsets.right)
        if attributes.messageTopLabelAlignment.textAlignment == .left{
            iconX = attributes.messageTopLabelAlignment.textInsets.left
        }else{
            iconX = self.frame.width - attributes.messageTopLabelAlignment.textInsets.right - attributes.messageTopLabelSize.width - paddingIcon
        }
        iconMarkReply.frame = CGRect(x: iconX, y: y + messageTopLabel.textInsets.top/2 + (attributes.messageTopLabelSize.height - iconMarkReplySize.height)/2, width: iconMarkReplySize.width, height: iconMarkReplySize.height)
        messageTopLabel.frame = CGRect(origin: origin, size: CGSize(width: self.frame.width, height: attributes.messageTopLabelSize.height))
    }

    /// Positions the message bubble's bottom label.
    /// - attributes: The `MessagesCollectionViewLayoutAttributes` for the cell.
    open func layoutMessageBottomLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageBottomLabel.textAlignment = attributes.messageBottomLabelAlignment.textAlignment
        messageBottomLabel.textInsets = attributes.messageBottomLabelAlignment.textInsets

        let y: CGFloat
        if messageBodyView.frame.size != .zero{
            y = messageBodyView.frame.maxY + attributes.messageContainerPadding.bottom
        }else{
            y = actionBodyView.frame.maxY + attributes.actionBodyPadding.bottom
        }
        
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
            origin.y = messageBodyView.frame.minY
        case .messageBottom:
            origin.y = messageBodyView.frame.maxY - attributes.accessoryViewSize.height
        case .messageCenter:
            origin.y = messageBodyView.frame.midY - (attributes.accessoryViewSize.height / 2)
        case .cellBottom:
            origin.y = attributes.frame.height - attributes.accessoryViewSize.height
        default:
            break
        }

        // Accessory view is always on the opposite side of avatar
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = messageBodyView.frame.maxX + attributes.accessoryViewPadding.left
        case .cellTrailing:
            origin.x = messageBodyView.frame.minX - attributes.accessoryViewPadding.right - attributes.accessoryViewSize.width
        case .natural:
            fatalError(MessageKitError.avatarPositionUnresolved)
        }

        accessoryView.frame = CGRect(origin: origin, size: attributes.accessoryViewSize)
    }
    
    open func focusWhenLongPressMessage() {
        let view = messageBodyView
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
