//
//  CallMessageCell.swift
//  MessageKit
//
//  Created by Gapo on 10/22/20.
//

import UIKit

open class CallMessageCell: MessageContentCell {
        
    private let boundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        return view
    }()
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "callaudio_answer")
        return img
    }()
    let typeCallLabel: UILabel = {
        let label = UILabel()
        label.text = "Cuộc gọi"
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Gọi lại"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    open override func setupSubviews() {
        super.setupSubviews()
        self.isUserInteractionEnabled = true
        self.messageContainerView.addSubview(boundView)
        boundView.addSubview(imageView)
        boundView.addSubview(typeCallLabel)
        boundView.addSubview(descriptionLabel)
    }
    
    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        self.messageContainerView.backgroundColor = .clear
        switch message.kind {
        case .call(let image, let statusInfo, let callInfo):
            self.updateUI(image: image, statusInfo: statusInfo, callInfo: callInfo)
        default:
            break
        }
    }
    
    private func updateUI(image: UIImage?, statusInfo: String, callInfo: String) {
        
        self.imageView.image = image
        self.typeCallLabel.text = statusInfo
        self.descriptionLabel.text = callInfo
        boundView.frame = self.messageContainerView.bounds
        let contentInset = MKMessageConstant.ContentInsets.Call.statusIcon
        
        let imageOriginX: CGFloat = contentInset.left
        let imageOriginY: CGFloat = boundView.frame.midY - MKMessageConstant.Sizes.Call.statusIcon.height/2
        imageView.frame = CGRect(imageOriginX, imageOriginY, MKMessageConstant.Sizes.Call.statusIcon.width, MKMessageConstant.Sizes.Call.statusIcon.height)

        let callInfoInset = MKMessageConstant.ContentInsets.Call.callInfo
        let typeCallOriginX: CGFloat = imageView.frame.maxX + callInfoInset.left
        typeCallLabel.frame = CGRect(typeCallOriginX, imageOriginY + 1, self.boundView.bounds.width - imageView.frame.maxX - callInfoInset.horizontal, 19)

        descriptionLabel.frame = CGRect(typeCallOriginX, imageView.frame.origin.x + imageView.frame.width - 15 - 1, typeCallLabel.frame.width, 15)
    }
    
    
    
}
