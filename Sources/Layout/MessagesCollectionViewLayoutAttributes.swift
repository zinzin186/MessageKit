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

/// The layout attributes used by a `MessageCollectionViewCell` to layout its subviews.
open class MessagesCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {

    // MARK: - Properties

    public var avatarSize: CGSize = .zero
    public var sendStatusSize: CGSize = CGSize(width: 14, height: 14)
    public var avatarPosition = AvatarPosition(vertical: .cellBottom)
    public var sendStatusPosition = AvatarPosition(vertical: .messageBottom)
    public var avatarLeadingTrailingPadding: CGFloat = 0
    public var sendStatusLeadingTrailingPadding: CGFloat = 0
    public var messageContainerSize: CGSize = .zero
    public var messageContainerPadding: UIEdgeInsets = .zero
    public var replyBodySize: CGSize = .zero
    public var replyBodyPadding: UIEdgeInsets = .zero
    public var messageLabelFont: UIFont = UIFont.preferredFont(forTextStyle: .body)
    public var messageLabelInsets: UIEdgeInsets = .zero

    public var cellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    public var cellTopLabelSize: CGSize = .zero
    
    public var cellBottomLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    public var cellBottomLabelSize: CGSize = .zero
    
    public var messageTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    public var messageTopLabelSize: CGSize = .zero

    public var messageBottomLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    public var messageBottomLabelSize: CGSize = .zero

    public var messageTimeLabelSize: CGSize = .zero

    public var accessoryViewSize: CGSize = .zero
    public var accessoryViewPadding: HorizontalEdgeInsets = .zero
    public var accessoryViewPosition: AccessoryPosition = .messageCenter
    
    public var iconMarkReplySize: CGSize = .zero

    public var linkPreviewFonts = LinkPreviewFonts(titleFont: .preferredFont(forTextStyle: .footnote),
                                                   teaserFont: .preferredFont(forTextStyle: .caption2),
                                                   domainFont: .preferredFont(forTextStyle: .caption1))
    
    // MARK: - Methods

    open override func copy(with zone: NSZone? = nil) -> Any {
        // swiftlint:disable force_cast
        let copy = super.copy(with: zone) as! MessagesCollectionViewLayoutAttributes
        copy.avatarSize = avatarSize
        copy.avatarPosition = avatarPosition
        copy.avatarLeadingTrailingPadding = avatarLeadingTrailingPadding
        copy.replyBodySize = replyBodySize
        copy.messageContainerSize = messageContainerSize
        copy.replyBodyPadding = replyBodyPadding
        copy.messageContainerPadding = messageContainerPadding
        copy.messageLabelFont = messageLabelFont
        copy.messageLabelInsets = messageLabelInsets
        copy.cellTopLabelAlignment = cellTopLabelAlignment
        copy.cellTopLabelSize = cellTopLabelSize
        copy.cellBottomLabelAlignment = cellBottomLabelAlignment
        copy.cellBottomLabelSize = cellBottomLabelSize
        copy.iconMarkReplySize = iconMarkReplySize
        copy.messageTimeLabelSize = messageTimeLabelSize
        copy.messageTopLabelAlignment = messageTopLabelAlignment
        copy.messageTopLabelSize = messageTopLabelSize
        copy.messageBottomLabelAlignment = messageBottomLabelAlignment
        copy.messageBottomLabelSize = messageBottomLabelSize
        copy.accessoryViewSize = accessoryViewSize
        copy.accessoryViewPadding = accessoryViewPadding
        copy.accessoryViewPosition = accessoryViewPosition
        copy.linkPreviewFonts = linkPreviewFonts
        return copy
        // swiftlint:enable force_cast
    }

    open override func isEqual(_ object: Any?) -> Bool {
        // MARK: - LEAVE this as is
        if let attributes = object as? MessagesCollectionViewLayoutAttributes {
            return super.isEqual(object) && attributes.avatarSize == avatarSize
                && attributes.avatarPosition == avatarPosition
                && attributes.avatarLeadingTrailingPadding == avatarLeadingTrailingPadding
                && attributes.replyBodySize == replyBodySize
                && attributes.messageContainerSize == messageContainerSize
                && attributes.replyBodyPadding == replyBodyPadding
                && attributes.messageContainerPadding == messageContainerPadding
                && attributes.messageLabelFont == messageLabelFont
                && attributes.messageLabelInsets == messageLabelInsets
                && attributes.cellTopLabelAlignment == cellTopLabelAlignment
                && attributes.cellTopLabelSize == cellTopLabelSize
                && attributes.cellBottomLabelAlignment == cellBottomLabelAlignment
                && attributes.cellBottomLabelSize == cellBottomLabelSize
                && attributes.iconMarkReplySize == iconMarkReplySize
                && attributes.messageTimeLabelSize == messageTimeLabelSize
                && attributes.messageTopLabelAlignment == messageTopLabelAlignment
                && attributes.messageTopLabelSize == messageTopLabelSize
                && attributes.messageBottomLabelAlignment == messageBottomLabelAlignment
                && attributes.messageBottomLabelSize == messageBottomLabelSize
                && attributes.accessoryViewSize == accessoryViewSize
                && attributes.accessoryViewPadding == accessoryViewPadding
                && attributes.accessoryViewPosition == accessoryViewPosition
                && attributes.linkPreviewFonts == linkPreviewFonts
        } else {
            return false
        }
    }
}
