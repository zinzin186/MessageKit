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

    

//    open override func messageContainerMaxWidth(for message: MKMessageType) -> CGFloat {
//        switch message.kind {
//        case .linkPreview:
//            let maxWidth = super.messageContainerMaxWidth(for: message)
//            return max(maxWidth, (layout?.collectionView?.bounds.width ?? 0) * 0.75)
//        default:
//            return super.messageContainerMaxWidth(for: message)
//        }
//    }

//    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
//        guard case MKMessageKind.linkPreview(let linkItem) = message.kind else {
//            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
//        }
//        let dummyMessage = ConcreteMessageType(sender: message.sender,
//                                               messageId: message.messageId,
//                                               sentDate: message.sentDate,
//                                               kind: linkItem.textKind, action: message.action)
//
//        var containerSize = super.messageContainerSize(for: dummyMessage, indexPath: indexPath)
//        containerSize.width = max(containerSize.width, messageContainerMaxWidth(for: message))
//        let maxWidth = containerSize.width
//        let labelInsets: UIEdgeInsets = messageLabelInsets(for: dummyMessage)
//        let minHeight = containerSize.height + maxWidth * LinkPreviewMessageSizeCalculator.imageRatio
//        let previewMaxWidth = containerSize.width// - (maxWidth + LinkPreviewMessageSizeCalculator.imageViewMargin + labelInsets.horizontal)
//        let previewMaxheight = maxWidth * LinkPreviewMessageSizeCalculator.imageRatio
//        calculateContainerSize(with: NSAttributedString(string: linkItem.title ?? "", attributes: [.font: titleFont]),
//                               containerSize: &containerSize,
//                               maxWidth: previewMaxWidth)
//
//        calculateContainerSize(with: NSAttributedString(string: linkItem.teaser, attributes: [.font: teaserFont]),
//                               containerSize: &containerSize,
//                               maxWidth: previewMaxWidth)
//
//        containerSize.height = max(minHeight, containerSize.height + previewMaxheight) + LinkPreviewMessageSizeCalculator.previewPaddingTopBottom * 2 + LinkPreviewMessageSizeCalculator.previewDescPaddingTitle + 10
//        return CGSize(width: 200, height: 200)
////        return containerSize
//    }

    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
                guard case MKMessageKind.linkPreview(let linkItem) = message.kind else {
                    fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
                }
                let dummyMessage = ConcreteMessageType(sender: message.sender,
                                                       messageId: message.messageId,
                                                       sentDate: message.sentDate,
                                                       kind: linkItem.textKind, action: message.action)

                var containerSize = super.messageContainerSize(for: dummyMessage, indexPath: indexPath)
                containerSize.width = max(containerSize.width, messageContainerMaxWidth(for: message))
            //containerSize of text message body
                let maxWidth = containerSize.width
    //        let labelInsets: UIEdgeInsets = UIEdgeInsets.init(top: 10, left: 13, bottom: 10, right: 13)
        let previewImageHeight = maxWidth * MKMessageConstant.Sizes.Preview.imageRatio
        let attibutedTitleString = NSAttributedString(string: "Những địa danh 'cô độc' nhất thế giới", attributes: [.font: self.linkPreviewFonts.titleFont])
        let previewTitleSize = labelSize(for: attibutedTitleString, considering: maxWidth - MKMessageConstant.Sizes.Preview.paddingLeftRight*2)
            let previewTitleHeight = previewTitleSize.height
            
        let attibutedTeaserString = NSAttributedString(string: linkItem.teaser, attributes: [.font: self.linkPreviewFonts.teaserFont])
            let previewTeaserSize = labelSize(for: attibutedTeaserString, considering: maxWidth - MKMessageConstant.Sizes.Preview.paddingLeftRight*2)
            let previewTeaserHeight = previewTeaserSize.height
            

            containerSize.height = containerSize.height + previewImageHeight + previewTitleHeight + previewTeaserHeight + MKMessageConstant.Sizes.Preview.paddingTopBottom*2 + MKMessageConstant.Sizes.Preview.descPaddingTitle
                return containerSize
        }
}

private extension LinkPreviewMessageSizeCalculator {
    private func calculateContainerSize(with attibutedString: NSAttributedString, containerSize: inout CGSize, maxWidth: CGFloat) {
        guard !attibutedString.string.isEmpty else { return }
        let size = labelSize(for: attibutedString, considering: maxWidth)
        containerSize.height += size.height
    }
}
