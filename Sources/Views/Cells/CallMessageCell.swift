//
//  CallMessageCell.swift
//  MessageKit
//
//  Created by Gapo on 10/22/20.
//

import UIKit

open class CallMessageCell: MessageContentCell {
        
    var callBackTappCell: (()->Void)?
    private let boundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage(named: "callaudio_answer")
        img.translatesAutoresizingMaskIntoConstraints = false
        return img
    }()
    let typeCallLabel: UILabel = {
        let label = UILabel()
        label.text = "Cuộc gọi"
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
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
    lazy var callButton: UIButton = {[unowned self] in
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(makeACall), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.backgroundColor = .systemPink
        button.isEnabled = true
        return button
    }()
    @objc private func makeACall(){
        print("tappppppp")
        self.callBackTappCell?()
    }
    
    open override func setupSubviews() {
        super.setupSubviews()
        self.isUserInteractionEnabled = true
        self.messageContainerView.addSubview(boundView)
        boundView.fillSuperview()
        self.addImageView()
        self.addTypeCallLabel()
        self.addTextLabel()
//        self.addCallButton()
    }
    
    private func addImageView(){
        boundView.addSubview(imageView)
        let contentInset = MKMessageConstant.ContentInsets.Call.statusIcon
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.boundView.leadingAnchor, constant: contentInset.left),
            imageView.centerYAnchor.constraint(equalTo: self.boundView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: MKMessageConstant.Sizes.Call.statusIcon.width),
            imageView.heightAnchor.constraint(equalToConstant: MKMessageConstant.Sizes.Call.statusIcon.width)
        ])
    }
    private func addTypeCallLabel(){
        boundView.addSubview(typeCallLabel)
        let contentInset = MKMessageConstant.ContentInsets.Call.callInfo
        NSLayoutConstraint.activate([
            typeCallLabel.leadingAnchor.constraint(equalTo: self.imageView.trailingAnchor, constant: contentInset.left),
            typeCallLabel.topAnchor.constraint(equalTo: self.imageView.topAnchor, constant: 1),
            typeCallLabel.heightAnchor.constraint(equalToConstant: 19),
            typeCallLabel.trailingAnchor.constraint(equalTo: self.boundView.trailingAnchor, constant: -contentInset.left)
        ])
    }
    private func addTextLabel(){
        boundView.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: self.typeCallLabel.leadingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: -1),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 15),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.typeCallLabel.trailingAnchor)
        ])
    }
    private func addCallButton(){
        boundView.addSubview(callButton)
        callButton.fillSuperview()
    }
    
    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        let isOutgoing = dataSource.isFromCurrentSender(message: message)
        self.messageContainerView.backgroundColor = .clear
        switch message.kind {
        case .call(let status, let duration):
            self.updateUI(status: status, duration: duration, isOutgoing: isOutgoing)
            
        default:
            break
        }
    }
    
    private func updateUI(status: Int, duration: Int, isOutgoing: Bool) {
        let statusImage: UIImage?
        let typeCallLabel: String?
        var callInfoString = self.showTimeActive(time: duration)
        switch status {
        case 0:
            if duration == 0{
                statusImage = MKMessageConstant.Images.Call.reject
                typeCallLabel = "Nhấn để gọi lại"
            } else {
                statusImage = MKMessageConstant.Images.Call.outgoing
                typeCallLabel = "Cuộc gọi đi"
            }
            
        case 1:
            if duration == 0{
                statusImage = MKMessageConstant.Images.Call.reject
                typeCallLabel = "Nhấn để gọi lại"
            } else {
                statusImage = MKMessageConstant.Images.Call.incoming
                typeCallLabel = "Cuộc gọi đến"
            }
            
        case 2:
            statusImage = MKMessageConstant.Images.Call.reject
            typeCallLabel = "Từ chối cuộc gọi"
            callInfoString = "Nhấn để gọi lại"
        case 3:
            statusImage = MKMessageConstant.Images.Call.misscall
            typeCallLabel = "Cuộc gọi nhỡ"
            callInfoString = "Nhấn để gọi lại"
        default:
            statusImage = nil
            typeCallLabel = nil
        }
        self.imageView.image = statusImage
        self.typeCallLabel.text = typeCallLabel
        self.descriptionLabel.text = callInfoString
    }
    
    private func showTimeActive(time: Int)->String{
        if time < 60{
            return "\(time) giây"
        }
        return "\((time + 30)/60) phút"
    }
    
}
