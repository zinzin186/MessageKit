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
            progressUpload.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor),
            progressUpload.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor),
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
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    // MARK: - Methods

    /// Responsible for setting up the constraints of the cell's subviews.
    open func setupConstraints() {
        imageView.fillSuperview()
        playButtonView.centerInSuperview()
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
        self.progressUpload.isHidden = true
        self.progressUpload.progress = 0
    }

    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        switch message.kind {
        case .photo(let mediaItem), .sticker(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = true
        case .video(let mediaItem):
            imageView.image = mediaItem.image ?? mediaItem.placeholderImage
            playButtonView.isHidden = false
        default:
            break
        }
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
    
}
