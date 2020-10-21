//
//  DonateMessageCell.swift
//  MessageKit
//
//  Created by Din Vu Dinh on 10/11/20.
//

import UIKit

class DonateMessageCell: TextMessageCell {
    
    lazy var donateView: DonateView = {
        let view = DonateView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(donateView)
//        NSLayoutConstraint.activate([
//            donateView.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor,
//                                          constant: 0),
//            donateView.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor,
//                                           constant: 0),
//            donateView.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor,
//                                         constant: 0)
//        ])
    }
    
    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .donate(donateInfo, _) = message.kind else { fatalError("Failed decorate donate cell") }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
        let textFont = displayDelegate.textFont(for: message, at: indexPath, in: messagesCollectionView)
        let attributedText = NSAttributedString(string: donateInfo, attributes: [NSAttributedString.Key.font : textFont])
        var donateInfoSize = labelSize(for: attributedText, considering: messageContainerView.bounds.width)
        let contentInset: UIEdgeInsets = MKMessageConstant.ContentInsets.donate
        let coinIconSize: CGSize = MKMessageConstant.Sizes.Donate.iconCoin
        donateInfoSize.width += (contentInset.left + 4 + coinIconSize.width + contentInset.right)
        donateInfoSize.height += (contentInset.top + contentInset.bottom)
        if donateInfoSize.height < MKMessageConstant.Sizes.Donate.donateInfoHeight {
            donateInfoSize.height = MKMessageConstant.Sizes.Donate.donateInfoHeight
        }
        
        
        donateView.frame = CGRect(origin: CGPoint.zero, size: donateInfoSize)
        messageLabel.frame = CGRect(0, donateInfoSize.height + 2, messageContainerView.bounds.width, messageContainerView.bounds.height)
        messageLabel.backgroundColor = MKMessageConstant.Colors.Donate.background
        donateView.lblAmountCoin.text = donateInfo
        donateView.lblAmountCoin.textColor = textColor
        donateView.lblAmountCoin.font = textFont
                
    }

    internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
}
