//
//  DonateMessageCell.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/11/20.
//

import UIKit

class DonateMessageCell: MessageContentCell {
    
    // MARK: - Properties

    /// The `MessageCellDelegate` for the cell.
    open override weak var delegate: MKMessageCellDelegate? {
        didSet {
            messageLabel.delegate = delegate
        }
    }

    /// The label used to display the message's text.
    open lazy var messageLabel: MessageLabel = {
        let label = MessageLabel()
        messageTextView.addSubview(label)
        label.textInsets = messageInsets
        return label
    }()
    
    var donateView: DonateView = {
        let view = DonateView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    lazy var messageTextView: UIView = {
        let view = UIView()
        view.backgroundColor = MKMessageConstant.Colors.Donate.background
        messageContainerView.addSubview(view)
        return view
    }()

    private var messageInsets: UIEdgeInsets = .zero
    // MARK: - Methods

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageInsets = attributes.messageLabelInsets
        }
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        messageLabel.attributedText = nil
        messageLabel.text = nil
    }
    
    
    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(donateView)
    }
    
    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .donate(donateInfo, messageText) = message.kind else { fatalError("Failed decorate donate cell") }
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        let isOutgoingMessage = dataSource.isFromCurrentSender(message: message)
        
        var messageTextSize: CGSize = CGSize.zero
        if let text = messageText {
            let attributes = displayDelegate.textAttributes(for: message, at: indexPath, in: messagesCollectionView)
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            messageLabel.attributedText = attributedString
            messageTextSize = MessageSizeCalculator.labelSize(for: attributedString, considering: messageContainerView.bounds.width - messageInsets.horizontal)
            messageTextSize.width += messageInsets.horizontal
            messageTextSize.height += messageInsets.vertical
            if messageTextSize.height < MKMessageConstant.Limit.minContainerBodyHeight{
                messageTextSize.height = MKMessageConstant.Limit.minContainerBodyHeight
            }
        }
        
        let donateAttributes = displayDelegate.donateTextAttributes(at: indexPath, in: messagesCollectionView)
        let attributedDonateInfoText = NSAttributedString(string: donateInfo, attributes: donateAttributes)
        donateView.lblAmountCoin.attributedText = attributedDonateInfoText
        var donateInfoSize = MessageSizeCalculator.labelSize(for: attributedDonateInfoText, considering: messageContainerView.bounds.width)
        let contentInset: UIEdgeInsets = MKMessageConstant.ContentInsets.donate
        let coinIconSize: CGSize = MKMessageConstant.Sizes.Donate.iconCoin
        donateInfoSize.width += (contentInset.left + 4 + coinIconSize.width + contentInset.right)
        donateInfoSize.height += (contentInset.top + contentInset.bottom)
        if donateInfoSize.height < MKMessageConstant.Sizes.Donate.donateInfoHeight {
            donateInfoSize.height = MKMessageConstant.Sizes.Donate.donateInfoHeight
        }
        if isOutgoingMessage {
            donateView.frame = CGRect(origin: CGPoint(x: messageContainerView.bounds.width - donateInfoSize.width, y: 0), size: donateInfoSize)
            if messageTextSize != .zero {
                messageTextView.frame = CGRect(origin: CGPoint(x: messageContainerView.bounds.width - messageTextSize.width, y: donateView.frame.maxY + 2), size: messageTextSize)
                self.cornerTextMessageView(isOutgoing: isOutgoingMessage)
            }
        } else {
            donateView.frame = CGRect(origin: CGPoint.zero, size: donateInfoSize)
            if messageTextSize != .zero {
                messageTextView.frame = CGRect(origin: CGPoint(x: 0, y: donateView.frame.maxY + 2), size: messageTextSize)
                self.cornerTextMessageView(isOutgoing: isOutgoingMessage)
            }
        }
        messageLabel.frame = messageTextView.bounds
        self.cornerDonateView(isOutgoing: isOutgoingMessage, hasMessageText: !(messageText?.isEmpty ?? true))
        self.messageContainerView.backgroundColor = UIColor.clear
    }
    
    open override func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        return messageLabel.handleGesture(touchPoint)
    }
    
    private func cornerDonateView(isOutgoing: Bool, hasMessageText: Bool) {
        var corners: UIRectCorner = []
        if hasMessageText {
            corners.formUnion(.topLeft)
            corners.formUnion(.topRight)
             if isOutgoing {
                 corners.formUnion(.bottomLeft)
             } else {
                 corners.formUnion(.bottomRight)
             }
        } else {
            corners.formUnion(.topLeft)
            corners.formUnion(.topRight)
            corners.formUnion(.bottomLeft)
            corners.formUnion(.bottomRight)
        }
        
        let radius: CGFloat = 16
        let smallCorner: CGFloat = 4
        donateView.layer.cornerRadius = smallCorner
        let path = UIBezierPath(roundedRect: donateView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        donateView.layer.mask = mask
    }
    
    private func cornerTextMessageView(isOutgoing: Bool) {
        var corners: UIRectCorner = []
        corners.formUnion(.bottomLeft)
        corners.formUnion(.bottomRight)
         if isOutgoing {
             corners.formUnion(.topLeft)
         } else {
             corners.formUnion(.topRight)
         }
        let radius: CGFloat = 16
        let smallCorner: CGFloat = 4
        messageTextView.layer.cornerRadius = smallCorner
        messageTextView.clipsToBounds = true
        let path = UIBezierPath(roundedRect: messageTextView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        messageTextView.layer.mask = mask
    }
}
