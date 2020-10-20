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
import MapKit
import MessageKit
import PINRemoteImage

class BasicExampleViewController: ChatViewController {
    override func configureMessageCollectionView() {
//        super.configureMessageCollectionView()
//        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {return}
//        layout.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageBottom))
//        layout.setMessageOutgoingAvatarPosition(AvatarPosition(vertical: .messageBottom))
//        layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 50)))
//        layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 12)))
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {return}
        self.configFlowLayout(layout)
    }
    
    private func configFlowLayout(_ layout: MessagesCollectionViewFlowLayout) {
        layout.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 17)))
        layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)))

        // Set outgoing avatar to overlap with the message bubble
        layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)))
        layout.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageBottom))
        let paddingRight = UIScreen.main.bounds.size.width - (MKMessageConstant.calcMaxWidthCell() + 10 + 60)
        layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: paddingRight))
        layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: paddingRight, bottom: 0, right: 2))
        //cellBottomLabelAttributedText
        layout.setMessageOutgoingCellBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout.setMessageIncomingCellBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout.setMessageOutgoingAccessoryViewSize(CGSize(width: 10, height: 10))
        layout.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        layout.setMessageOutgoingAccessoryViewPosition(.messageBottom)
//        let linkPreviewFonts = LinkPreviewFonts(titleFont: ChatUtils.previewTitleFont,
//                                   teaserFont: ChatUtils.previewDescFont,
//                                   domainFont: ChatUtils.previewTitleFont)
//        layout.setLinkPreviewFonts(linkPreviewFonts)
    }
//    override func messageTimestampLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        return NSAttributedString(string: "dsfdsfdsfd")
//    }
    func messageTimestampLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "dsfdsfdsfd")
    }
    
}

// MARK: - MessagesDisplayDelegate

extension BasicExampleViewController: MKMessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if case MessageKind.donate = message.kind {
            return UIColor.yellow
        }
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func textFont(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIFont {
        if case MessageKind.donate = message.kind {
            return UIFont.boldSystemFont(ofSize: 20)
        }
        return UIFont.systemFont(ofSize: 15)
    }
    func detectorAttributes(for detector: DetectorType, and message: MKMessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mentionRange: return [.foregroundColor: UIColor.blue, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0)]
        default: return MessageLabel.defaultAttributes
        }
    }
    
//    func enabledDetectors(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
//        return [.url, .address, .phoneNumber, .date, .transitInformation, .mentionRange([MentionInfo(range: NSRange(location: 1, length: 4), target: "targetMention"), MentionInfo(range: NSRange(location: 8, length: 2), target: "targetMention1")]), .hashtag]
//    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
            imageView.pin_setImage(from: imageURL)
        } else {
            imageView.pin_cancelImageDownload()
        }
    }
    
    func configureLinkPreviewImageView(_ imageView: UIImageView, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        imageView.pin_setImage(from: URL(string: "https://avatars0.githubusercontent.com/u/2911921?s=460&u=418a6180264738f33cf0ea2b6ce1c9fd79d992f2&v=4")!)
    }
    
    func configureSendStatusView(_ sendStatusView: UIImageView, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        sendStatusView.isHidden = false
        sendStatusView.backgroundColor = .red

    }
    
    func configureActionMessageImageView(_ imageView: UIImageView, for action: ActionType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch action {
        case .reply(let message):
            if case MessageKind.photo(let media) = message.kind, let imageURL = media.url {
                imageView.pin_setImage(from: imageURL)
            }
        case .story(let urlString):
            if let imageURL = URL(string: urlString) {
                imageView.pin_setImage(from: imageURL)
            }
        default:
            break
        }
        
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MKMessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "ic_map_marker")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(2, 2, 2)
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions(showsBuildings: true, showsPointsOfInterest: true, span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10))
    }

    // MARK: - Audio Messages

    func audioTintColor(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor(red: 15/255, green: 135/255, blue: 255/255, alpha: 1.0)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MKMessageType) {
        audioController.configureAudioCell(cell, message: message) // this is needed especily when the cell is reconfigure while is playing sound
    }

}

// MARK: - MessagesLayoutDelegate

extension BasicExampleViewController: MKMessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    func messageTopLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}
