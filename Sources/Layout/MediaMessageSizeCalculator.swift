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
import UIKit

open class MediaMessageSizeCalculator: TextMessageSizeCalculator {

    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        let sizeForMediaItem = { (maxWidth: CGFloat, item: MediaItem) -> CGSize in
            if maxWidth < item.size.width {
                // Maintain the ratio if width is too great
                let height = maxWidth * item.size.height / item.size.width
                return CGSize(width: maxWidth, height: height)
            }
            return item.size
        }
        switch message.kind {
        case .photo(let item), .video(let item), .sticker(let item):
            let mediaSize = sizeForMediaItem(maxWidth, item)
            if (item.content) != nil {
                let messageInsets = messageLabelInsets(for: message)
                let maxWidthCotent = mediaSize.width - messageInsets.horizontal
//                let maxWidth = super.messageContainerMaxWidth(for: message)
                var messageContainerSize: CGSize
                let attributedText = self.genAttributeMessage(with: message, at: indexPath)
                if attributedText.string.isEmpty {
                    messageContainerSize = CGSize.zero
                } else {
                    messageContainerSize = labelSize(for: attributedText, considering: maxWidthCotent)
                    messageContainerSize.width += messageInsets.horizontal
                    messageContainerSize.height += messageInsets.vertical
                    if messageContainerSize.height < MKMessageConstant.Limit.minContainerBodyHeight{
                        messageContainerSize.height = MKMessageConstant.Limit.minContainerBodyHeight
                    }
                }
//                let messageWidth: CGFloat = max(mediaSize.width, messageContainerSize.width)
                return CGSize(width: mediaSize.width, height: messageContainerSize.height + mediaSize.height + 2)
            }
            return mediaSize
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
    }
    
}
