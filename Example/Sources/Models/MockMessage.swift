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
import CoreLocation
import MessageKit
import AVFoundation


enum MKCallType: Int {
    case audio = 0
    case video = 1
    var iconName: String {
        switch self {
        case .audio:
            return "audiocall"
        case .video:
            return "videocall"
        }
    }
}

enum MKCallStatus: Int {
    case call = 0
    case incoming = 1
    case outgoing = 2
    case decline = 3
    case calling = 4
    case hangup = 5
    case miss = 6
    case admin_hangup = 7
    case no_answer = 8
    case cancel = 9
    
    var iconName: String {
        switch self {
        case .incoming:
            return "incoming"
        case .outgoing:
            return "outgoing"
        case .decline:
            return "decline"
        case .calling:
            return "calling"
        case .hangup:
            return "hangup"
        case .miss:
            return "miss"
        case .admin_hangup:
            return "admin_hangup"
        case .no_answer:
            return "no_answer"
        case .cancel:
            return "cancel"
        case .call:
            return "call"
        }
    }
    
    var statusName: String {
        switch self {
        case .incoming:
            return "Cuộc gọi đến"
        case .outgoing:
            return "Cuộc gọi đi"
        case .decline:
            return "Từ chối cuộc gọi"
        case .calling:
            return "Đang gọi"
        case .hangup:
            return "Kết thúc cuộc gọi"
        case .miss:
            return "Cuộc gọi nhỡ"
        case .admin_hangup:
            return "Admin kết thúc"
        case .no_answer:
            return "Không trả lời"
        case .cancel:
            return "Cuộc gọi bị huỷ"
        case .call:
            return "Đang gọi"
        }
    }
    
    func getImage(type: MKCallType) -> UIImage? {
        return UIImage(named: "ic_\(type.iconName)_\(self.iconName)")
    }
    
}




private struct CoordinateItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }

}

private struct ImageMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    var path: String?
    var urlString: String?

    init(image: UIImage) {
        self.image = image
        let imageWidth: CGFloat = UIScreen.main.bounds.size.height
        let imageHeight: CGFloat = UIScreen.main.bounds.size.width
        let maxHeight: CGFloat = UIScreen.main.bounds.size.width
        let maxWidth: CGFloat = UIScreen.main.bounds.size.width * 237/375
        if imageWidth/imageHeight < maxWidth/maxHeight {
            let newWidth = imageWidth * maxHeight / imageHeight
            self.size = CGSize(width: newWidth, height: maxHeight)
        } else {
            let newHeight = imageHeight * maxHeight / imageWidth
            self.size = CGSize(width: maxWidth, height: newHeight)
        }

//        self.size = CGSize(width: 1000, height: 2400)
        self.placeholderImage = UIImage()
    }

    init(imageURL: URL) {
        self.url = imageURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}

private struct MockAudiotem: AudioItem {

    var url: URL
    var size: CGSize
    var duration: Float

    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        // compute duration
        let audioAsset = AVURLAsset(url: url)
        self.duration = Float(CMTimeGetSeconds(audioAsset.duration))
    }

}

struct MockContactItem: ContactItem {
    
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}

struct MockLinkItem: LinkItem {
    let text: String
    let attributedText: NSAttributedString?
    let url: URL
    let title: String?
    let teaser: String
    let thumbnailImage: UIImage?
}

internal struct ReplyMessage: MKReplyMessageType {
    var messageId: String
    var sender: MKSenderType {
        return user
    }
    var sentDate: Date
//    var kind: MKMessageKind

    var user: MockUser
    var content: String
    var medias: [String]?
    var deleted: Bool
    
    init(user: MockUser, messageId: String, date: Date, content: String, medias: [String]? = nil, deleted: Bool = false) {
//        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.content = content
        self.medias = medias
        self.deleted = deleted
    }
}

struct MKLinkItem: LinkItem {
    let text: String
    let attributedText: NSAttributedString?
    let url: URL
    let title: String?
    let teaser: String
    let thumbnailImage: UIImage?
}

internal struct MockMessage: MKMessageType {

    var messageId: String
    var sender: MKSenderType {
        return user
    }
    var sentDate: Date
    var kind: MKMessageKind

    var user: MockUser
    var action: MKActionType

    private init(kind: MKMessageKind, user: MockUser, messageId: String, date: Date, action: MKActionType) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.action = action
    }
    
    init(custom: Any?, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
//        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date, action: action)
        self.init(kind: .action("Someone left the conversation"), user: user, messageId: messageId, date: date, action: action)
    }

    init(text: String, user: MockUser, messageId: String, date: Date) {
        var mediaItem = ImageMediaItem(imageURL: URL(string: "https://files-5.gapo.vn/sticker/origin/0b58cc57-93f1-4427-b461-17a9c526b1b2.json")!)
        //https://files-5.gapo.vn/sticker/origin/0b58cc57-93f1-4427-b461-17a9c526b1b2.json
        let id: String = "https://files-5.gapo.vn/sticker/origin/0b58cc57-93f1-4427-b461-17a9c526b1b2.json"
//        if let path = StickerLoader.pathSticker(id) {
//            mediaItem.path = path
//        }
        mediaItem.urlString = id
        let replyMessage = ReplyMessage(user: user, messageId: messageId, date: date, content: "Cuộc gọi Âm thanh", medias: ["https://avatars0.githubusercontent.com/u/2911921?s=460&u=418a6180264738f33cf0ea2b6ce1c9fd79d992f2&v=4"], deleted: false)
        let action = MKActionType.reply(replyMessage: replyMessage)
//        let action = MKActionType.remove
//        let action = MKActionType.story(urlString: "https://avatars0.githubusercontent.com/u/2911921?s=460&u=418a6180264738f33cf0ea2b6ce1c9fd79d992f2&v=4")
//        self.init(kind: .donate(amount: "Gui tang 10.000", message: "Tang doanate"), user: user, messageId: messageId, date: date, action: .default)
        let callType = MKCallType.init(rawValue: 1)!
        let statusType = MKCallStatus.init(rawValue: 1)!
        let statusImage: UIImage? = statusType.getImage(type: callType)
        let callInfoString = MockMessage.showTimeActive(time: 120)
        let attributedText1 = NSMutableAttributedString(string: "Nội dung được gửi không hỗ trợ trên phiên bản này, vui lòng cập nhật phiên bản mới nhất ", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.lightGray])
        let attributedText2 = NSAttributedString(string: "tại đây", attributes: [.font: UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.green])
        attributedText1.append(attributedText2)
        self.init(kind: .attributedText(attributedText1), user: user, messageId: messageId, date: date, action: action)
//        self.init(kind: .call(image: statusImage, statusInfo: statusType.statusName, callInfo: callInfoString), user: user, messageId: messageId, date: date, action: .default)
        self.init(kind: .sticker(mediaItem), user: user, messageId: messageId, date: date, action: .default)
//        self.init(kind: .action(text), user: user, messageId: messageId, date: date, action: .default)
        
//        let gPLinkItem = MKLinkItem(
//            text: "https://vnexpress.net/nhung-dia-danh-co-doc-nhat-the-gioi-2882673.html",
//            attributedText: nil,
//            url: URL(string: "https://vnexpress.net/nhung-dia-danh-co-doc-nhat-the-gioi-2882673.html")!,
//            title: "Những địa danh 'cô độc' nhất thế giới",
//            teaser: "Vì nhiều lý do, những địa điểm dưới đây luôn vắng bóng người sinh sống và trở nên “cô đơn” nhất trên trái đất.",
//            thumbnailImage: nil
//        )
//        self.init(kind: .linkPreview(gPLinkItem), user: user, messageId: messageId, date: date, action: .default)
    }

    init(attributedText: NSAttributedString, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date, action: action)
    }

    init(image: UIImage, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(imageURL: URL, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        let mediaItem = ImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(thumbnail: UIImage, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(location: CLLocation, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(emoji: String, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date, action: action)
    }

    init(audioURL: URL, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        let audioItem = MockAudiotem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(contact: MockContactItem, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date, action: action)
    }

    init(linkItem: LinkItem, user: MockUser, messageId: String, date: Date, action: MKActionType = .default) {
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date, action: action)
    }
    
    static func showTimeActive(time: Int) ->String{
        if time == 0 {
            return "Nhấn để gọi lại"
        }
        if time < 60 {
            return "\(time) giây"
        }
        if time < 60*60 {
            let seconds = time%60
            let secondsString = seconds > 0 ? "\(seconds) giây" : ""
            return "\(time/60) phút \(secondsString)"
        }
        return "\(time/3600) giờ \(MockMessage.showTimeActive(time: time%60/60))"
    }
}
