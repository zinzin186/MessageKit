//
//  MessageConstant.swift
//  MessageKit
//
//  Created by Gapo on 10/20/20.
//

import UIKit

public enum MKMessageConstant {
    
    static let previewPaddingTopBottom: CGFloat = 10.0
    static let previewDescPaddingTitle: CGFloat = 4

    //Mention chat
    static let mentionDisplayName = "All"
    static let mentionAllTarget = "all"
    static let phoneRegex: String = "\\b[0-9]{8,11}\\b"
    static let urlRegex: String = "(^|[\\s.:;?\\-\\]<\\(])" +
        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    // MARK: - Static functions

    static public func calcMaxWidthMessage() -> CGFloat {
        return UIScreen.main.bounds.size.width * 237/375
    }

    static public func calcMaxWidthImageThumb() -> CGFloat {
        return UIScreen.main.bounds.size.width / 2
    }

    static public func calcMaxHeightImageThumb() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }

    static public func calcMaxWidthCell() -> CGFloat {
        return calcMaxWidthMessage() + 12 * 2
    }

    static public func calcPreviewHeightImage() -> CGFloat {
        let widthImage = calcMaxWidthCell()
        let heightImage = widthImage * 133 / 237
        return heightImage
    }
    
    enum ActionView {
        enum ReplyView {
            static let contentMediaInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
            static let mediaSize: CGSize = CGSize(width: 40, height: 40)
            static let mediaRadius: CGFloat = 4
            static let contentTextInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            static let bottomPadding: CGFloat = -24
            
        }
        
        enum StoryView {
            static let bottomPadding: CGFloat = 5
            static let mediaRadius: CGFloat = 4
            static let mediaSize: CGSize = CGSize(width: 68, height: 98)
        }
        
        enum RemoveView {
            static let contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            static let bottomPadding: CGFloat = 0
        }
        static let backgroundColor: UIColor = UIColor.fromHexCode("#F6F6F6")
        static let cornerRadius: CGFloat = 10
    }
    static let replyImage: UIImage? = UIImage(named: "mk_icon_chat_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
    static let markReplyImage: UIImage? = UIImage(named: "mk_icon_mark_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
}
