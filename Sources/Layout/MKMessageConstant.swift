//
//  MKMessageConstant.swift
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
            static let bottomPadding: CGFloat = -18
            static let contentFont: UIFont = UIFont.systemFont(ofSize: 13)
            static let rightReplyIconPadding: CGFloat = 4
            
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
        static let cornerRadius: CGFloat = 14
    }
    enum ActionNote {
        static let contentInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        static let bottomPadding: CGFloat = 0
    }
    
    enum Images {
        static let replyImage: UIImage? = UIImage(named: "mk_icon_chat_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        static let markReplyImage: UIImage? = UIImage(named: "mk_icon_mark_reply", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
        enum Call {
            
            enum Video {
                static let incoming: UIImage? = UIImage(named: "ic_videocall_incoming", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static let outgoing: UIImage? = UIImage(named: "ic_videocall_outgoing", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static let misscall: UIImage? = UIImage(named: "ic_videocall_misscall", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static let hangup: UIImage? = UIImage(named: "ic_videocall_hangup", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
            }
            
            enum Audio {
                static let incoming: UIImage? = UIImage(named: "ic_audiocall_incoming", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static let outgoing: UIImage? = UIImage(named: "ic_audiocall_outgoing", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static let misscall: UIImage? = UIImage(named: "ic_audiocall_misscall", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
                static let hangup: UIImage? = UIImage(named: "ic_audiocall_hangup", in: Bundle.messageKitAssetBundle, compatibleWith: nil)
            }
        }
    }
    
    
    enum Limit {
        static let minContainerBodyHeight: CGFloat = abs(MKMessageConstant.ActionView.ReplyView.bottomPadding) * 2
        static let maxActionReplyTextHeight: CGFloat = 36
    }
    
    enum Fonts {
        static let amountDonate: UIFont = UIFont.boldSystemFont(ofSize: 16)
    }
    
    enum Colors {
        
        enum Donate {
            static let background: UIColor = UIColor.fromHexCode("9E57D1")
            static let text: UIColor = UIColor.fromHexCode("#FFD600")
        }
    }
    
    enum Sizes {
        
        enum Donate {
            static let iconCoin: CGSize = CGSize(width: 16, height: 16)
            static let donateInfoHeight: CGFloat = 36
        }
        
        enum Call {
            static let callView: CGSize = CGSize(width: 210, height: 64)
            static let statusIcon: CGSize = CGSize(width: 40, height: 40)
        }
        
        enum Preview {
            static let paddingTopBottom: CGFloat = 10.0
            static let descPaddingTitle: CGFloat = 4
            static let paddingLeftRight: CGFloat = 12
            static let imageRatio: CGFloat = 133.0 / 237.0
        }
    }
    
    enum ContentInsets {
        static let donate: UIEdgeInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
        enum Text {
            static let incomingMessageLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            static let outgoingMessageLabelInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        }
        enum Call {
            static let statusIcon: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
            static let callInfo: UIEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        }
        
    }
    
    
}
