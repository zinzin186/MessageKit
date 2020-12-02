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

    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        guard case MKMessageKind.linkPreview(let linkItem) = message.kind else {
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        if case MKActionType.remove = message.action {
            return CGSize.zero
        }
        let dummyMessage = ConcreteMessageType(sender: message.sender,
                                               messageId: message.messageId,
                                               sentDate: message.sentDate,
                                               kind: linkItem.textKind, action: message.action)

        var containerSize = super.messageContainerSize(for: dummyMessage, indexPath: indexPath)
        containerSize.width = max(containerSize.width, getPreviewMessageMaxWidth(for: message))
        //containerSize of text message body
        let maxWidth = containerSize.width
        let previewImageHeight = maxWidth * MKMessageConstant.Sizes.Preview.imageRatio
        var previewTitleSize: CGSize = .zero
        if let title = linkItem.title {
            let attibutedTitleString = NSAttributedString(string: title, attributes: [.font: self.linkPreviewFonts.titleFont])
            previewTitleSize = MessageSizeCalculator.labelSize(for: attibutedTitleString, considering: maxWidth - MKMessageConstant.Sizes.Preview.contentTextInset.horizontal)
        }
        let previewTitleHeight = previewTitleSize.height
            
        let attibutedTeaserString = NSAttributedString(string: linkItem.teaser, attributes: [.font: self.linkPreviewFonts.teaserFont])
        let previewTeaserSize = MessageSizeCalculator.labelSize(for: attibutedTeaserString, considering: maxWidth - MKMessageConstant.Sizes.Preview.contentTextInset.horizontal)
        let previewTeaserHeight = previewTeaserSize.height

        containerSize.height = containerSize.height + previewImageHeight + previewTitleHeight + previewTeaserHeight + MKMessageConstant.Sizes.Preview.contentTextInset.vertical + MKMessageConstant.Sizes.Preview.descPaddingTitle
                return containerSize
    }
    
    private func getPreviewMessageMaxWidth(for message: MKMessageType) -> CGFloat {
        let avatarWidth = avatarSize(for: message).width
        let messagePadding = messageContainerPadding(for: message)
        let accessoryWidth = accessoryViewSize(for: message).width
        let accessoryPadding = accessoryViewPadding(for: message)
        return messagesLayout.itemWidth - avatarWidth - messagePadding.horizontal - accessoryWidth - accessoryPadding.horizontal - avatarLeadingTrailingPadding
    }
}

private extension LinkPreviewMessageSizeCalculator {
    private func calculateContainerSize(with attibutedString: NSAttributedString, containerSize: inout CGSize, maxWidth: CGFloat) {
        guard !attibutedString.string.isEmpty else { return }
        let size = MessageSizeCalculator.labelSize(for: attibutedString, considering: maxWidth)
        containerSize.height += size.height
    }
}
