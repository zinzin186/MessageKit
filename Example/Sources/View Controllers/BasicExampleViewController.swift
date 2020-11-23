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
import Lottie

class BasicExampleViewController: ChatViewController {
    var dicAnimations: [String: Animation] = [:]
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
        setupLongGestureOnCollectionView()
    }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    func setupLongGestureOnCollectionView() {
//        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
//        longPressedGesture.minimumPressDuration = 0.3
//        longPressedGesture.delegate = self
//        messagesCollectionView.addGestureRecognizer(longPressedGesture)
    }
    
    @objc func longPress() {
        print("longpress..............")
    }
    
    private func configFlowLayout(_ layout: MessagesCollectionViewFlowLayout) {
        layout.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        // Hide the outgoing avatar and adjust the label alignment to line up with the messages
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.setMessageIncomingCellTopLabelAlignment(LabelAlignment(textAlignment: .center, textInsets: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)))
        layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 17)))
        layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)))

        // Set outgoing avatar to overlap with the message bubble
        layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 5, left: 40, bottom: 0, right: 0)))
        layout.setMessageIncomingAvatarSize(CGSize(width: 30, height: 30))
        layout.setMessageIncomingAvatarPosition(AvatarPosition(vertical: .messageBottom))
        let paddingRight = UIScreen.main.bounds.size.width - (ChatUtils.calcMaxWidthCell() + 10 + 60)
        layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 5, bottom: 0, right: paddingRight))
        layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: paddingRight + 55, bottom: 0, right: 2))
        //cellBottomLabelAttributedText
        layout.setMessageOutgoingCellTopLabelAlignment(LabelAlignment(textAlignment: .center, textInsets: UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)))
        layout.setMessageOutgoingCellBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout.setMessageIncomingCellBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)))
        layout.setMessageIncomingAccessoryViewSize(CGSize(width: 30, height: 30))
        layout.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 8, right: 0))
        layout.setMessageIncomingAccessoryViewPosition(.messageBottom)
        layout.setMessageOutgoingAccessoryViewSize(CGSize(width: 10, height: 10))
        layout.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 8))
        layout.setMessageOutgoingAccessoryViewPosition(.messageBottom)
        let linkPreviewFonts = LinkPreviewFonts(titleFont: ChatUtils.previewTitleFont,
                                   teaserFont: ChatUtils.previewDescFont,
                                   domainFont: ChatUtils.previewTitleFont)
        layout.setLinkPreviewFonts(linkPreviewFonts)
    }

//    override func messageTimestampLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        return NSAttributedString(string: "dsfdsfdsfd")
//    }
    func messageTimestampLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "dsfdsfdsfd")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - MessagesDisplayDelegate

extension BasicExampleViewController: MKMessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textAttributes(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = MessageConstant.Sizes.Message.lineSpacing
        var textFont: UIFont = Font.SFProText.regular.with(size: MessageConstant.Sizes.Message.fontSize)
//        if let gpMessage = self.getMessageAtIndexPath(indexPath), ChatUtils.checkMessageIsEmoji(message: gpMessage){
//            textFont = Font.SFProText.regular.with(size: MessageConstant.Sizes.Message.fontSizeEmoji)
//        }
        if case MKMessageKind.donate = message.kind {
            return [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: UIColor.white, .paragraphStyle: paragraphStyle]
        }
        let isMe = isFromCurrentSender(message: message)
        let textColor = isMe ? UIColor.white: UIColor.fromHex("#1A1A1A")
        return [NSAttributedString.Key.font: textFont, NSAttributedString.Key.foregroundColor: textColor, .paragraphStyle: paragraphStyle]
    }
    
    func donateTextAttributes(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [NSAttributedString.Key: Any] {
        return [NSAttributedString.Key.font: Font.SFProText.semibold.with(size: 16), NSAttributedString.Key.foregroundColor: MessageConstant.Colors.Donate.text]
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
        if case MKMessageKind.attributedText = message.kind {
            return UIColor.clear
        }
        return isFromCurrentSender(message: message) ? .primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if case .sticker = message.kind {
            return MessageStyle.none
        }
        
        var corners: UIRectCorner = []
        if case .default = message.action {
            if isFromCurrentSender(message: message) {
                corners.formUnion(.topLeft)
                corners.formUnion(.bottomLeft)
                corners.formUnion(.topRight)
                corners.formUnion(.bottomRight)
            } else {
                corners.formUnion(.topRight)
                corners.formUnion(.bottomRight)
                corners.formUnion(.topLeft)
                corners.formUnion(.bottomLeft)
            }
        } else {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
        }
       
        return .custom { view in
            let radius: CGFloat = 16
            let smallCorner: CGFloat = 4
            view.layer.cornerRadius = smallCorner
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
            switch message.kind {
            case .video, .attributedText:
                let borderLayer = CAShapeLayer()
                let borderPath = path
                borderLayer.fillColor = UIColor.clear.cgColor
                borderLayer.strokeColor = UIColor.fromHex("#EDEDED").cgColor
                borderLayer.path = borderPath.cgPath
                borderLayer.frame = view.bounds
                borderLayer.lineWidth = 1.5
                view.borderLayer?.removeFromSuperlayer()
                view.layer.addSublayer(borderLayer)
                view.layer.borderColor = UIColor.fromHex("#EDEDED").cgColor
                view.layer.borderWidth = 1
                view.borderLayer = borderLayer
            default:
                view.borderLayer?.removeFromSuperlayer()
                view.layer.borderColor = UIColor.clear.cgColor
                view.layer.borderWidth = 0
            }
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
        avatarView.set(avatar: avatar)
    }

    func configureMediaMessageImageView(_ cell: MediaMessageCell, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if case MKMessageKind.photo(let media) = message.kind, let urlString = media.urlString, let imageURL = URL(string: urlString) {
            cell.imageView.pin_setImage(from: imageURL)
        } else {
            cell.imageView.pin_cancelImageDownload()
        }
    }
    
    func setupViewBodySticker(animationView: AnimationView, cell: StickerMessageCell) {
        cell.animationView?.removeFromSuperview()
        animationView.loopMode = .loop
        cell.imageView.addSubview(animationView)
        cell.animationView = animationView
        animationView.fillSuperview()
        animationView.play()
    }
    func configureLinkPreviewImageView(_ imageView: UIImageView, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        imageView.pin_setImage(from: URL(string: "https://avatars0.githubusercontent.com/u/2911921?s=460&u=418a6180264738f33cf0ea2b6ce1c9fd79d992f2&v=4")!)
    }
    
    func configureSendStatusView(_ sendStatusView: UIImageView, for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        sendStatusView.isHidden = false
        sendStatusView.backgroundColor = .red

    }
    
    func configureActionMessageImageView(_ imageView: UIImageView, for action: MKActionType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        switch action {
        case .reply(let message):
            if let urlString = message.medias?.first, let imageURL = URL(string: urlString) {
//                imageView.pin_setImage(from: imageURL)
                if urlString.hasSuffix("json") {
                    self.loadAnimationSticker(imageURL, imageView: imageView)
                } else {
                    imageView.pin_setImage(from: imageURL)
                }
            }
            imageView.backgroundColor = .red
        case .story(let urlString):
            if let imageURL = URL(string: urlString) {
                imageView.pin_setImage(from: imageURL)
            }
        default:
            break
        }
        
    }
    func loadAnimationSticker(_ url: URL, imageView: UIImageView) {
        let animationReplyView = AnimationView()
        animationReplyView.loopMode = .loop
        imageView.addSubview(animationReplyView)
        imageView.image = nil
//        animationReplyView.fillSuperview()
//        let contentInset = MKMessageConstant.ActionView.ReplyView.contentMediaInset
//        let imageHeight: CGFloat = superViewFrame.height - contentInset.vertical
        animationReplyView.frame = imageView.bounds
        Animation.loadedFrom(url: url, closure: { [weak self] (animation) in
            guard let self = self else {return}
            animationReplyView.animation = animation
            animationReplyView.play()
            }, animationCache: LRUAnimationCache.sharedCache)
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

    func configureTextForActionMessage(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        return [
            NSAttributedString.Key.foregroundColor: UIColor.lightGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13),
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
    }
}

// MARK: - MessagesLayoutDelegate

extension BasicExampleViewController: MKMessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
//    func cellBottomLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 17
//    }
    
//    func messageTopLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 20
//    }
    
    func messageBottomLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func cellBottomLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MKMessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 30
        
    }
}
internal extension UIView {

func fillSuperview() {
    guard let superview = self.superview else {
        return
    }
    translatesAutoresizingMaskIntoConstraints = false

    let constraints: [NSLayoutConstraint] = [
        leftAnchor.constraint(equalTo: superview.leftAnchor),
        rightAnchor.constraint(equalTo: superview.rightAnchor),
        topAnchor.constraint(equalTo: superview.topAnchor),
        bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ]
    NSLayoutConstraint.activate(constraints)
}
}
