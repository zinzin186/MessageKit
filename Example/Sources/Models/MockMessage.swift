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
    let text: String?
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
    var kind: MessageKind

    var user: MockUser
    
    init(kind: MessageKind, user: MockUser, messageId: String, date: Date) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
    }
}

internal struct MockMessage: MKMessageType {

    var messageId: String
    var sender: MKSenderType {
        return user
    }
    var sentDate: Date
    var kind: MessageKind

    var user: MockUser
    var action: ActionType

    private init(kind: MessageKind, user: MockUser, messageId: String, date: Date, action: ActionType) {
        self.kind = kind
        self.user = user
        self.messageId = messageId
        self.sentDate = date
        self.action = action
    }
    
    init(custom: Any?, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
//        self.init(kind: .custom(custom), user: user, messageId: messageId, date: date, action: action)
        self.init(kind: .action("Someone left the conversation"), user: user, messageId: messageId, date: date, action: action)
    }

    init(text: String, user: MockUser, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(imageURL: URL(string: "https://avatars0.githubusercontent.com/u/2911921?s=460&u=418a6180264738f33cf0ea2b6ce1c9fd79d992f2&v=4")!)
        let replyMessage = ReplyMessage(kind: .photo(mediaItem), user: user, messageId: messageId, date: date)
//        let action = ActionType.reply(replyMessage: replyMessage)
        let action = ActionType.remove
//        let action = ActionType.story(urlString: "https://avatars0.githubusercontent.com/u/2911921?s=460&u=418a6180264738f33cf0ea2b6ce1c9fd79d992f2&v=4")
        self.init(kind: .text("Tin nhắn đã bị xoá"), user: user, messageId: messageId, date: date, action: action)
    }

    init(attributedText: NSAttributedString, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        self.init(kind: .attributedText(attributedText), user: user, messageId: messageId, date: date, action: action)
    }

    init(image: UIImage, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(imageURL: URL, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        let mediaItem = ImageMediaItem(imageURL: imageURL)
        self.init(kind: .photo(mediaItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(thumbnail: UIImage, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(location: CLLocation, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        let locationItem = CoordinateItem(location: location)
        self.init(kind: .location(locationItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(emoji: String, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        self.init(kind: .emoji(emoji), user: user, messageId: messageId, date: date, action: action)
    }

    init(audioURL: URL, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        let audioItem = MockAudiotem(url: audioURL)
        self.init(kind: .audio(audioItem), user: user, messageId: messageId, date: date, action: action)
    }

    init(contact: MockContactItem, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        self.init(kind: .contact(contact), user: user, messageId: messageId, date: date, action: action)
    }

    init(linkItem: LinkItem, user: MockUser, messageId: String, date: Date, action: ActionType = .default) {
        self.init(kind: .linkPreview(linkItem), user: user, messageId: messageId, date: date, action: action)
    }
}
