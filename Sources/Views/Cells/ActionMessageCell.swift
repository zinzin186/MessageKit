//
//  ActionMessageCell.swift
//  InputBarAccessoryView
//
//  Created by Din Vu Dinh on 10/7/20.
//

import UIKit

//open class ActionMessageCell: UICollectionViewCell {
//
//    private let label = UILabel()
//
//    public override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupSubviews()
//    }
//
//    public required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        setupSubviews()
//    }
//    open override func prepareForReuse() {
//        super.prepareForReuse()
//        label.text = nil
//    }
//    open func setupSubviews() {
//        contentView.addSubview(label)
//        label.numberOfLines = 0
//        label.lineBreakMode = .byWordWrapping
//
//    }
//
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        label.frame = contentView.bounds
//    }
//
//    open func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
//        switch message.kind {
//        case .action(let text):
//            let displayDelegate = messagesCollectionView.messagesDisplayDelegate
//            let attributedText = NSAttributedString(string: text, attributes: displayDelegate?.configureTextForActionMessage(at: indexPath, in: messagesCollectionView))
//            label.attributedText = attributedText
//        default:
//            break
//        }
//    }
//
//}

open class ActionMessageCell: MessageCollectionViewCell, UIGestureRecognizerDelegate {
    
    open weak var delegate: MKMessageCellDelegate?
    
    open var cellTopLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    open var messageActionLabel: InsetLabel = {
        let label = InsetLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        return label
    }()
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSubviews()
    }
    open override func prepareForReuse() {
        super.prepareForReuse()
        messageActionLabel.text = nil
        cellTopLabel.text = nil
    }
    open func setupSubviews() {
        contentView.addSubview(messageActionLabel)
        contentView.addSubview(cellTopLabel)
        
        
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        // Call this before other laying out other subviews
        
        layoutCellTopLabel(with: attributes)
        layoutMessageActionLabel(with: attributes)
        
    }
    
    open func layoutCellTopLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        cellTopLabel.textAlignment = attributes.cellTopLabelAlignment.textAlignment
        cellTopLabel.textInsets = attributes.cellTopLabelAlignment.textInsets
        cellTopLabel.frame = CGRect(origin: .zero, size: CGSize(width: self.contentView.frame.width, height: attributes.cellTopLabelSize.height))
    }
    
    open func layoutMessageActionLabel(with attributes: MessagesCollectionViewLayoutAttributes) {
        messageActionLabel.textAlignment = .center
        let messageActionSize = attributes.messageContainerSize
        let y = cellTopLabel.frame.height
        let origin = CGPoint(x: 0, y: y)
        messageActionLabel.frame = CGRect(origin: origin, size: messageActionSize)
        
    }
    
    
    open func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        let messageTimestampLabelText = dataSource.messageTimestampLabelAttributedText(for: message, at: indexPath)
        cellTopLabel.attributedText = messageTimestampLabelText
        delegate = messagesCollectionView.messageCellDelegate
        switch message.kind {
        case .action(let text):
            let displayDelegate = messagesCollectionView.messagesDisplayDelegate
            let attributedText = NSAttributedString(string: text, attributes: displayDelegate?.configureTextForActionMessage(at: indexPath, in: messagesCollectionView))
            messageActionLabel.attributedText = attributedText
            messageActionLabel.textInsets = MKMessageConstant.ActionNote.contentInset
        default:
            break
        }
    }
    
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        delegate?.didTapBackground(in: self)
    }
}
