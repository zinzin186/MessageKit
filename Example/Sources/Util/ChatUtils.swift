//
//  ChatUtils.swift
//  ChatExample
//
//  Created by Gapo on 11/11/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit
import AVFoundation

enum MessageCellPosition: Int, CaseIterable {
    case cellPaddingBottom = 0
//    case cellPreview = 1
    case cellMessage = 1
    case cellName = 2
    case cellTime = 3
    case cellPaddingTop = 4
}

class ChatUtils {
    
    static let previewTitleFont = Font.SFProText.semibold.with(size: 16)
    static let previewDescFont = Font.SFProText.regular.with(size: 12)
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

    static func calcMaxWidthMessage() -> CGFloat {
        return UIScreen.main.bounds.size.width * 237/375
    }
    
    static func calcMaxWidthImageThumb() -> CGFloat {
        return UIScreen.main.bounds.size.width / 2
    }
    
    static func calcMaxHeightImageThumb() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    static func calcMaxWidthCell() -> CGFloat {
        return calcMaxWidthMessage() + MessageConstant.Sizes.Message.paddingLeftRight * 2
    }
    
    static func calcPreviewHeightImage() -> CGFloat {
        let widthImage = calcMaxWidthCell()
        let heightImage = widthImage * 133 / 237
        return heightImage
    }
    
    static func genAttributeActionNote(message: String?) -> NSAttributedString {
        let messageContent = message ?? ""
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = MessageConstant.Sizes.Message.lineSpacing
        let attrString = NSMutableAttributedString(string: messageContent)
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(.font, value: MessageConstant.Fonts.actionNote, range: NSMakeRange(0, attrString.length))
        return attrString
    }
    
    static func calcSizeTextPreview(text: String, font: UIFont) -> CGSize {
        if text.isEmpty {
            return .zero
        }
        let maxWidth: CGFloat = ChatUtils.calcMaxWidthMessage()
        let minHeight: CGFloat = MessageConstant.Sizes.Body.minHeight - MessageConstant.Sizes.Message.paddingTopBottom * CGFloat(2)
        let defaultSizeText: CGSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = MessageConstant.Sizes.Message.lineSpacing
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        attrString.addAttribute(.font, value: font, range: NSMakeRange(0, attrString.length))
        let sizeText: CGSize = NSString(string: text).boundingRect(with: defaultSizeText,
                                                                     options: [NSStringDrawingOptions.usesLineFragmentOrigin],
                                                                     attributes: attrString.attributes(at: 0, effectiveRange: nil),
                                                                     context: nil).size
        var sizeResult: CGSize = sizeText
        if sizeResult.height < minHeight {
            sizeResult = CGSize(width: sizeText.width, height: minHeight)
        }
        if sizeResult.width < MessageConstant.Sizes.Message.minWidth {
            sizeResult = CGSize(width: MessageConstant.Sizes.Message.minWidth, height: max(sizeResult.height, 24))
        }
        return sizeResult
    }
    
    static func calculateSize(text: String) -> CGSize {
        let maxWidth: CGFloat = ChatUtils.calcMaxWidthMessage()
        let minHeight: CGFloat = MessageConstant.Sizes.Body.minHeight - MessageConstant.Sizes.Message.paddingTopBottom * CGFloat(2)
        let defaultSizeText: CGSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let attrString = NSMutableAttributedString(string: text)
        attrString.addAttribute(.font, value: Font.SFProText.regular.with(size: MessageConstant.Sizes.Message.fontSize), range: NSMakeRange(0, attrString.length))
        let sizeText: CGSize = attrString.boundingRect(with: defaultSizeText,
        options: [NSStringDrawingOptions.usesLineFragmentOrigin],
        context: nil).size
        var sizeResult: CGSize = sizeText
        if sizeResult.height < minHeight {
            sizeResult = CGSize(width: sizeText.width, height: minHeight)
        }
        if sizeResult.width < MessageConstant.Sizes.Message.minWidth {
            sizeResult = CGSize(width: MessageConstant.Sizes.Message.minWidth, height: max(sizeResult.height, 24))
        }
        return sizeResult
    }
    
    static func calcSizeImageThumb(originSize: CGSize) -> CGSize {
        let maxWidthImage = calcMaxWidthImageThumb()
        let maxHeightImage = UIScreen.main.bounds.size.height * 1 / 2
        let originWidth = originSize.width
        let originHeight = originSize.height
        var resultWidth: CGFloat = 0
        if originWidth > maxWidthImage {
            resultWidth = maxWidthImage
        } else {
            resultWidth = originWidth
        }
        if resultWidth < 140 {
            resultWidth = 140
        }
        var resultHeight: CGFloat = resultWidth * originHeight / originWidth
        if resultHeight > maxHeightImage {
            resultHeight = maxHeightImage
        }
        if resultHeight < 100 {
            resultHeight = 100
        }
        return CGSize(width: resultWidth, height: resultHeight)
    }
    
    static func calcSizeVideoThumb(originSize: CGSize) -> CGSize {
        let maxWidthImage = calcMaxWidthImageThumb()
        let maxHeightImage = UIScreen.main.bounds.size.height * 1 / 2
        var expectHeight = maxHeightImage
        let originWidth = originSize.width
        let originHeight = originSize.height
        let realRatio: CGFloat = originHeight / originWidth
        if realRatio < MessageConstant.Sizes.minRatioImageThumb {
            expectHeight = maxWidthImage * MessageConstant.Sizes.minRatioImageThumb
        } else if realRatio > MessageConstant.Sizes.maxRatioImageThumb {
            expectHeight = maxWidthImage * MessageConstant.Sizes.maxRatioImageThumb
        } else {
            expectHeight = maxWidthImage * realRatio
        }
        return CGSize(width: maxWidthImage, height: expectHeight)
    }

    static func calcHeightCellName() -> CGFloat {
        return MessageConstant.Sizes.chatGroupNameHeight
    }
    
}
