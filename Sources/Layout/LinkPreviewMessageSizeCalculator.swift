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

import Foundation

open class LinkPreviewMessageSizeCalculator: TextMessageSizeCalculator {

    static let previewPaddingTopBottom: CGFloat = 10.0
    static let previewDescPaddingTitle: CGFloat = 4
    static let paddingLeftRight: CGFloat = 12
    static let imageRatio: CGFloat = 133.0 / 237.0

    public var titleFont: UIFont
    public var teaserFont: UIFont = .preferredFont(forTextStyle: .caption2)
    public var domainFont: UIFont

    public override init(layout: MessagesCollectionViewFlowLayout?) {
        let titleFont = UIFont.systemFont(ofSize: 13, weight: .semibold)
//        let titleFontMetrics = UIFontMetrics(forTextStyle: .footnote)
//        self.titleFont = titleFontMetrics.scaledFont(for: titleFont)
        self.titleFont = titleFont
        let domainFont = UIFont.systemFont(ofSize: 12, weight: .semibold)
//        let domainFontMetrics = UIFontMetrics(forTextStyle: .caption1)
//        self.domainFont = domainFontMetrics.scaledFont(for: domainFont)
        self.domainFont = domainFont

        super.init(layout: layout)
    }

    open override func messageContainerMaxWidth(for message: MKMessageType) -> CGFloat {
        switch message.kind {
        case .linkPreview:
            let maxWidth = super.messageContainerMaxWidth(for: message)
            return max(maxWidth, (layout?.collectionView?.bounds.width ?? 0) * 0.75)
        default:
            return super.messageContainerMaxWidth(for: message)
        }
    }

    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        guard case MessageKind.linkPreview(let linkItem) = message.kind else {
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        let dummyMessage = ConcreteMessageType(sender: message.sender,
                                               messageId: message.messageId,
                                               sentDate: message.sentDate,
                                               kind: linkItem.textKind, action: message.action)

        var containerSize = super.messageContainerSize(for: dummyMessage, indexPath: indexPath)
        containerSize.width = max(containerSize.width, messageContainerMaxWidth(for: message))
        let maxWidth = containerSize.width
        let labelInsets: UIEdgeInsets = messageLabelInsets(for: dummyMessage)
        let minHeight = containerSize.height + maxWidth * LinkPreviewMessageSizeCalculator.imageRatio
        let previewMaxWidth = containerSize.width// - (maxWidth + LinkPreviewMessageSizeCalculator.imageViewMargin + labelInsets.horizontal)
        let previewMaxheight = maxWidth * LinkPreviewMessageSizeCalculator.imageRatio
        calculateContainerSize(with: NSAttributedString(string: linkItem.title ?? "", attributes: [.font: titleFont]),
                               containerSize: &containerSize,
                               maxWidth: previewMaxWidth)

        calculateContainerSize(with: NSAttributedString(string: linkItem.teaser, attributes: [.font: teaserFont]),
                               containerSize: &containerSize,
                               maxWidth: previewMaxWidth)

        containerSize.height = max(minHeight, containerSize.height + previewMaxheight) + LinkPreviewMessageSizeCalculator.previewPaddingTopBottom * 2 + LinkPreviewMessageSizeCalculator.previewDescPaddingTitle + 10

        return containerSize
    }

    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
        titleFont = attributes.linkPreviewFonts.titleFont
        teaserFont = attributes.linkPreviewFonts.teaserFont
        domainFont = attributes.linkPreviewFonts.domainFont
    }
}

private extension LinkPreviewMessageSizeCalculator {
    private func calculateContainerSize(with attibutedString: NSAttributedString, containerSize: inout CGSize, maxWidth: CGFloat) {
        guard !attibutedString.string.isEmpty else { return }
        let size = labelSize(for: attibutedString, considering: maxWidth)
        containerSize.height += size.height
    }
}
