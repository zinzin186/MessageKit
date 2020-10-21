//
//  ActionMessageCell.swift
//  InputBarAccessoryView
//
//  Created by Din Vu Dinh on 10/7/20.
//

import UIKit

open class ActionMessageCell: UICollectionViewCell {
    
    private let label = UILabel()
    
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
        label.text = nil
    }
    open func setupSubviews() {
        contentView.addSubview(label)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = contentView.bounds
    }
    
    open func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        switch message.kind {
        case .action(let text):
            let displayDelegate = messagesCollectionView.messagesDisplayDelegate
            let attributedText = NSAttributedString(string: text, attributes: displayDelegate?.configureTextForActionMessage(at: indexPath, in: messagesCollectionView))
            label.attributedText = attributedText
        default:
            break
        }
    }
    
}
