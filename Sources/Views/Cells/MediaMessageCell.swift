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

import UIKit
import GTProgressBar

/// A subclass of `MessageContentCell` used to display video and audio messages.
open class MediaMessageCell: MessageContentCell {

    /// The play button view to display on video messages.
//    open lazy var playButtonView: PlayButtonView = {
//        let playButtonView = PlayButtonView()
//        return playButtonView
//    }()

    private var messageInsets: UIEdgeInsets = .zero
    
    open lazy var messageLabel: MessageLabel = {
        let label = MessageLabel()
        messageTextView.addSubview(label)
        label.fillSuperview()
        return label
    }()
    
    lazy var messageTextView: UIView = {
        let view = UIView()
        messageContainerView.addSubview(view)
        return view
    }()
    
    open lazy var progressUpload: GTProgressBar = {
        let progressUpload = GTProgressBar()
        progressUpload.orientation = GTProgressBarOrientation.horizontal
        progressUpload.barBackgroundColor = .white
        progressUpload.barFillColor = UIColor.fromHexCode("#6FBE49")
        progressUpload.displayLabel = false
        progressUpload.barBorderColor = .clear
        progressUpload.layer.borderWidth = 0
        progressUpload.barBorderWidth = 0
        progressUpload.barFillInset = 0
        progressUpload.progress = 0
        progressUpload.isHidden = true
        progressUpload.cornerType = GTProgressBarCornerType.square
        progressUpload.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.addSubview(progressUpload)
        NSLayoutConstraint.activate([
            progressUpload.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            progressUpload.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            progressUpload.heightAnchor.constraint(equalToConstant: 6),
            progressUpload.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor)
        ])
        return progressUpload
    }()
    
    public let playButtonView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "play", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        return imageView
    }()
    /// The image view display the media content.
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        playButtonView.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            playButtonView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            playButtonView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        playButtonView.constraint(equalTo: CGSize(width: 48, height: 48))
    }

    open override func setupSubviews() {
        super.setupSubviews()
        messageContainerView.addSubview(imageView)
        messageContainerView.addSubview(playButtonView)
        setupConstraints()
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.messageLabel.text = ""
        self.messageTextView.backgroundColor = .clear
        self.progressUpload.isHidden = true
        self.progressUpload.progress = 0
    }

    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let dataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        let sizeForMediaItem = { (maxWidth: CGFloat, item: MediaItem) -> CGSize in
            if maxWidth < item.size.width {
                // Maintain the ratio if width is too great
                let height = maxWidth * item.size.height / item.size.width
                return CGSize(width: maxWidth, height: height)
            }
            return item.size
        }
        let maxWidth = self.messageContainerView.frame.width
        var sizeItem: CGSize = .zero
        var content: String?
        switch message.kind {
        case .photo(let mediaItem), .sticker(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = true
            sizeItem = sizeForMediaItem(maxWidth, mediaItem)
            content = mediaItem.content
        case .video(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = false
            sizeItem = sizeForMediaItem(maxWidth, mediaItem)
            content = mediaItem.content
        default:
            break
        }
        
        
        let isOutgoingMessage = dataSource.isFromCurrentSender(message: message)
        var messageTextSize: CGSize = CGSize.zero
        if let text = content, !text.isEmpty {
            messageTextView.isHidden = false
            let attributes = displayDelegate.textAttributes(for: message, at: indexPath, in: messagesCollectionView)
            let attributedString = NSMutableAttributedString(string: text, attributes: attributes)
            messageLabel.textInsets = self.messageInsets
            messageLabel.attributedText = attributedString
            messageTextSize = labelSize(for: attributedString, considering: messageContainerView.bounds.width - self.messageInsets.horizontal)
            messageTextSize.width += messageInsets.horizontal
            messageTextSize.height += messageInsets.vertical
            if messageTextSize.height < MKMessageConstant.Limit.minContainerBodyHeight{
                messageTextSize.height = MKMessageConstant.Limit.minContainerBodyHeight
            }
            guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
                fatalError(MessageKitError.nilMessagesDisplayDelegate)
            }

            let messageColor = displayDelegate.backgroundColor(for: message, at: indexPath, in: messagesCollectionView)
            if isOutgoingMessage {
                messageTextView.frame = CGRect(origin: CGPoint(x: messageContainerView.bounds.width - messageTextSize.width, y: 0), size: messageTextSize)
                self.cornerTextMessageView(isOutgoing: isOutgoingMessage)
                messageTextView.backgroundColor = messageColor
                imageView.frame = CGRect(origin: CGPoint(x: messageContainerView.bounds.width - sizeItem.width, y: messageTextView.frame.maxY + 2), size: sizeItem)
            } else {
                messageTextView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: messageTextSize)
                self.cornerTextMessageView(isOutgoing: isOutgoingMessage)
                messageTextView.backgroundColor = messageColor
                imageView.frame = CGRect(origin: CGPoint(x: 0, y: messageTextView.frame.maxY + 2), size: sizeItem)
            }
        } else {
            imageView.frame = messageContainerView.bounds
            messageTextView.isHidden = true
        }
        self.cornerImageView(isOutgoing: isOutgoingMessage, hasMessageText: !(content?.isEmpty ?? true))
        self.messageContainerView.backgroundColor = UIColor.clear
        
        
        displayDelegate.configureMediaMessageImageView(self, for: message, at: indexPath, in: messagesCollectionView)

        
    }
    
    /// Handle tap gesture on contentView and its subviews.
    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: imageView)

        guard imageView.frame.contains(touchLocation) else {
            super.handleTapGesture(gesture)
            return
        }
        delegate?.didTapImage(in: self)
    }
    
    internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let constraintBox = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: constraintBox, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).integral

        return rect.size
    }
    
    private func cornerTextMessageView(isOutgoing: Bool) {
        var corners: UIRectCorner = []
        corners.formUnion(.topLeft)
        corners.formUnion(.topRight)
         if isOutgoing {
             corners.formUnion(.bottomLeft)
         } else {
             corners.formUnion(.bottomRight)
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
    
    private func cornerImageView(isOutgoing: Bool, hasMessageText: Bool) {
        var corners: UIRectCorner = []
        if hasMessageText {
            corners.formUnion(.bottomLeft)
            corners.formUnion(.bottomRight)
             if isOutgoing {
                 corners.formUnion(.topLeft)
             } else {
                 corners.formUnion(.topRight)
             }
        } else {
            corners.formUnion(.topLeft)
            corners.formUnion(.topRight)
            corners.formUnion(.bottomLeft)
            corners.formUnion(.bottomRight)
        }
        
        let radius: CGFloat = 16
        let smallCorner: CGFloat = 4
        imageView.layer.cornerRadius = smallCorner
        let path = UIBezierPath(roundedRect: imageView.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        imageView.layer.mask = mask
        
        let borderLayer = CAShapeLayer()
        let borderPath = path
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = UIColor.fromHexCode("#EDEDED").cgColor
        borderLayer.path = borderPath.cgPath
        borderLayer.frame = imageView.bounds
        borderLayer.lineWidth = 1.5
        self.messageContainerView.borderLayer?.removeFromSuperlayer()
        self.layer.addSublayer(borderLayer)
        self.layer.borderColor = UIColor.fromHexCode("#EDEDED").cgColor
        self.layer.borderWidth = 1
        self.messageContainerView.borderLayer = borderLayer
    }
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageInsets = attributes.messageLabelInsets
        }
    }
}
