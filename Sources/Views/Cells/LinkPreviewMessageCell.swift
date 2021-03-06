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

open class LinkPreviewMessageCell: TextMessageCell {
    
    public lazy var linkPreviewView: LinkPreviewView = {
        let view = LinkPreviewView()
        view.backgroundColor = UIColor.fromHexCode("#F1F1F1")
        view.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.addSubview(view)
//        view.fillSuperview()
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor,
                                          constant: 0),
            view.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor,
                                           constant: 0),
            view.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor,
                                         constant: 0)
        ])
        return view
    }()

    private var linkURL: URL?

    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes else { return }
        linkPreviewView.titleLabel.font = attributes.linkPreviewFonts.titleFont
        linkPreviewView.teaserLabel.font = attributes.linkPreviewFonts.teaserFont
    }

    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        if case MKActionType.remove = message.action {
            super.configure(with: message, at: indexPath, and: messagesCollectionView)
            return
        }
        let displayDelegate = messagesCollectionView.messagesDisplayDelegate

//        if let textColor: UIColor = displayDelegate?.textColor(for: message, at: indexPath, in: messagesCollectionView) {
//            linkPreviewView.titleLabel.textColor = textColor
//            linkPreviewView.teaserLabel.textColor = textColor
//        }

        guard case MKMessageKind.linkPreview(let linkItem) = message.kind else {
            fatalError("LinkPreviewMessageCell received unhandled MessageDataType: \(message.kind)")
        }

        let dummyMessage = ConcreteMessageType(sender: message.sender,
                                               messageId: message.messageId,
                                               sentDate: message.sentDate,
                                               kind: linkItem.textKind, action: message.action)
        super.configure(with: dummyMessage, at: indexPath, and: messagesCollectionView)

        linkPreviewView.titleLabel.text = linkItem.title
        linkPreviewView.teaserLabel.text = linkItem.teaser
        linkPreviewView.imageView.image = linkItem.thumbnailImage
        linkURL = linkItem.url

        displayDelegate?.configureLinkPreviewImageView(linkPreviewView.imageView, for: message, at: indexPath, in: messagesCollectionView)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        linkPreviewView.titleLabel.text = nil
        linkPreviewView.teaserLabel.text = nil
        linkPreviewView.imageView.image = nil
        linkURL = nil
    }

    open override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)
        let messageFrameConvert = convert(messageContainerView.frame, from: messageBodyView)
        switch true {
        case messageFrameConvert.contains(touchLocation):
            if !cellContentView(canHandle: convert(touchLocation, to: messageContainerView)) {
                delegate?.didSelectURL(linkURL!)
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
}
