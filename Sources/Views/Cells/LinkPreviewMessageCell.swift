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
    
    var linkPreviewView: LinkPreviewView!

    private var linkURL: URL?

    open override func configure(with message: MKMessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        if case MKActionType.remove = message.action {
            super.configure(with: message, at: indexPath, and: messagesCollectionView)
            return
        }
        let displayDelegate = messagesCollectionView.messagesDisplayDelegate
        guard case MKMessageKind.linkPreview(let linkItem) = message.kind else {
            fatalError("LinkPreviewMessageCell received unhandled MessageDataType: \(message.kind)")
        }

        let dummyMessage = ConcreteMessageType(sender: message.sender,
                                               messageId: message.messageId,
                                               sentDate: message.sentDate,
                                               kind: linkItem.textKind, action: message.action)
        super.configure(with: dummyMessage, at: indexPath, and: messagesCollectionView)
       
        let maxWidth = self.messageContainerView.frame.width
        let flowLayout = messagesCollectionView.messagesCollectionViewFlowLayout
        let linkPreviewFonts = flowLayout.linkPreviewMessageSizeCalculator.linkPreviewFonts
        let previewImageHeight = maxWidth * MKMessageConstant.Sizes.Preview.imageRatio
        var previewTitleSize: CGSize = .zero
        if let title = linkItem.title {
            let attibutedTitleString = NSAttributedString(string: title, attributes: [.font: linkPreviewFonts.titleFont])
            previewTitleSize = MessageSizeCalculator.labelSize(for: attibutedTitleString, considering: maxWidth - MKMessageConstant.Sizes.Preview.contentTextInset.horizontal)
        }
        let previewTitleHeight = previewTitleSize.height
            
        let attibutedTeaserString = NSAttributedString(string: linkItem.teaser, attributes: [.font: linkPreviewFonts.teaserFont])
        let previewTeaserSize = MessageSizeCalculator.labelSize(for: attibutedTeaserString, considering: maxWidth - MKMessageConstant.Sizes.Preview.contentTextInset.horizontal)
        let previewTeaserHeight = previewTeaserSize.height

        let heightPreviewView = previewImageHeight + previewTitleHeight + previewTeaserHeight + MKMessageConstant.Sizes.Preview.contentTextInset.vertical + MKMessageConstant.Sizes.Preview.descPaddingTitle
        let linkPreviewFrame = CGRect(0, self.messageContainerView.bounds.height - heightPreviewView, self.messageContainerView.bounds.width, heightPreviewView)
        linkPreviewView = LinkPreviewView(frame: linkPreviewFrame, tesaserHeight: previewTeaserHeight)
        self.messageContainerView.addSubview(linkPreviewView)
//        linkPreviewView.updateFrameSubviews(tesaserHeight: previewTeaserHeight)
        linkPreviewView.titleLabel.font = linkPreviewFonts.titleFont
        linkPreviewView.teaserLabel.font = linkPreviewFonts.teaserFont
        linkPreviewView.titleLabel.text = linkItem.title
        linkPreviewView.teaserLabel.text = linkItem.teaser
        linkPreviewView.imageView.image = linkItem.thumbnailImage
        linkURL = linkItem.url
        displayDelegate?.configureLinkPreviewImageView(linkPreviewView.imageView, for: message, at: indexPath, in: messagesCollectionView)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        if linkPreviewView != nil {
            linkPreviewView.titleLabel.text = nil
            linkPreviewView.teaserLabel.text = nil
            linkPreviewView.imageView.image = nil
        }
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
