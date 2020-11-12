//
//  MessageConstant.swift
//  ChatExample
//
//  Created by Gapo on 11/11/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit

enum MessageConstant {
    
    enum Sizes {
        enum Avatar {
            static let avatarSize: CGFloat = 32
            static let avatarPaddingLeft: CGFloat = 12
            static let avatarPaddingBottom: CGFloat = 1
        }
        enum Status {
            static let statusSize: CGFloat = 14
            static let statusPaddingLeft: CGFloat = 7
        }
        enum Body {
            static let minHeight: CGFloat = 36
            static let paddingLeftPartnerSend: CGFloat = 56
            static let paddingRightSuperViewMeSend: CGFloat = 24
        }
        enum Reply {
            static let contentPaddingTop: CGFloat = 11
            static let showHeight: CGFloat = 35
            static let showHeightImage: CGFloat = 55
            static let showHeightDeleted: CGFloat = 35
            static let imageSize: CGFloat = 40
            static let textHeight: CGFloat = 16
        }
        enum Message {
            static let paddingLeftRight: CGFloat = 12
            static let paddingTopBottom: CGFloat = 8
            static let fontSize: CGFloat = 16
            static let fontSizeEmoji: CGFloat = 40
            static let fontSizeDeleted: CGFloat = 15
            static let lineSpacing: CGFloat = 1.1
            static let paddingTextAndImage: CGFloat = 2
            static let minWidth: CGFloat = 24
            static let paddingActionNote: CGFloat = 2
        }
        enum Story {
            static let titleFontSize: CGFloat = 13.0
            static let contentPadding: CGFloat = 4.0
            static let titleHeight: CGFloat = 16.0
            static let imageWidth: CGFloat = 68.0
            static let imageHeight: CGFloat = 98.0
        }
        enum Donate {
            static let coinPreviewHeight: CGFloat = 36.0
            static let coinImageSize: CGFloat = 16.0
            static let coinAmountHeight: CGFloat = 22.0
            static let coinImagePadding: CGFloat = 5.0
            static let previewHorizonPadding: CGFloat = 12.0
            static let previewVerticalPadding: CGFloat = 7.0
            // Preview coin và message
            static let contentPadding: CGFloat = 2.0
            // Guid view
            static let guideHeight: CGFloat = 40
            static let guideWidth: CGFloat = 210
        }
        
        static let timeViewHeight: CGFloat = 39.0
        static let commonRadius: CGFloat = 18.0
        static let minRatioImageThumb: CGFloat = 2.0 / 3.0
        static let maxRatioImageThumb: CGFloat = 3.0 / 2.0
        static let chatGroupNameHeight: CGFloat = 17.0
        static let chatGroupSystemHeight: CGFloat = 24.0

    }
    
    enum NotificationNames {
        static let leaveGroup = NSNotification.Name(rawValue: "notificationLeaveGroup")
        static let kickedGroup = NSNotification.Name(rawValue: "notificationKickedGroup")
        static let updateInfoGroup = NSNotification.Name(rawValue: "notificationUpdateInfoGroup")
        static let contactPermissionChange = NSNotification.Name(rawValue: "notificationContactPermissionChange")
        static let updatePartnerReadCount = NSNotification.Name(rawValue: "notificationUpdatePartnerReadCount")
        static let resetPrivateChatCode             = NSNotification.Name(rawValue: "notificationResetPrivateChatCode")
        static let setPrivateForThread              = NSNotification.Name(rawValue: "notificationSetPrivateForThread")
        static let disablePrivateThread             = NSNotification.Name(rawValue: "notificationDisablePrivateThread")
        static let hasNewPrivateMessage             = NSNotification.Name(rawValue: "notificationHasNewPrivateMessage")
    }
    
    enum Fonts {
        static let actionNote: UIFont = Font.SFProText.medium.with(size: 13)
    }
    
    enum PlaceHolder {
        static let chatPlaceHolder: UIImage = UIImage(named: "chat-photo_placeholder-medium")!
        static let chatBackgroundHolderColor: UIColor = UIColor(hex: "F5F5F5")
    }
    
    enum Limits {
        static let kTimeLimitBetweenMessages: Double = 600 // 10 minutes
        static let PERIOD_PER_MESSAGES: Int = 500 // miliseconds
        static let limit_gif_size: Int = 4 * 1024 * 1024
        static let MESSAGES_PER_PAGE: Int = 50
        static let LIMIT_SHOW_DONATE_TOOLTIP: Int = 3
    }
    
    enum Colors {
        enum Donate {
            static let background: UIColor = UIColor(hex: "9E57D1")
            static let text: UIColor = UIColor(hex: "#FFD600")
        }
        
    }

}
