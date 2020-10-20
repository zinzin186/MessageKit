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

open class ActionBodyView: UIView {
    
    var clickReplyMessageCallback: (() -> Void)?
   
    private lazy var tapButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(self.tapReplyMessage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    @objc private func tapReplyMessage(){
        self.clickReplyMessageCallback?()
    }
    
    var actionRemoveMessageView: ActionRemoveMessageView?
    var actionReplyTextView: ActionReplyTextView?
    var actionReplyMediaView: ActionReplyMediaView?
    var actionChatFromStoryView: ActionChatFromStoryView?

    init() {
        super.init(frame: .zero)
    }

    func applyUI(isOutgoingMessage: Bool, message: MKMessageType){
        switch message.action {
        case .reply(let replyMessage):
            self.getContentText(message: replyMessage)
        case .story:
            self.addActionChatFromStoryView(image: nil)
        case .remove:
            if case MessageKind.text(let text) = message.kind {
                self.addActionRemoveMessageView(text: text)
            }else {
                self.addActionRemoveMessageView(text: "Tin nhắn đã bị xoá")
            }
        default:
            break
        }
        
        
    }
    func addActionRemoveMessageView(text: String){
        self.actionRemoveMessageView = ActionRemoveMessageView()
        self.actionRemoveMessageView?.contentLabel.text = text
        self.addActionView(view: self.actionRemoveMessageView!, bottomPadding: MKMessageConstant.ActionView.RemoveView.bottomPadding)
        
    }
   
    func addActionReplyTextView(text: String){
        self.actionReplyTextView = ActionReplyTextView()
        self.actionReplyTextView?.contentLabel.text = text
        self.addActionView(view: self.actionReplyTextView!, bottomPadding: MKMessageConstant.ActionView.ReplyView.bottomPadding)
        addButton()
        
    }
    func addActionReplyMediaView(text: String, image: UIImage?){
        self.actionReplyMediaView = ActionReplyMediaView()
        self.actionReplyMediaView?.messageLabel.text = text
        self.actionReplyMediaView?.imageView.image = image
        self.addActionView(view: self.actionReplyMediaView!, bottomPadding: MKMessageConstant.ActionView.ReplyView.bottomPadding)
        addButton()
    }
    
    func addActionChatFromStoryView(image: UIImage?){
        self.actionChatFromStoryView = ActionChatFromStoryView()
        self.actionChatFromStoryView?.imageView.image = image
        self.addActionView(view: self.actionChatFromStoryView!, bottomPadding: MKMessageConstant.ActionView.StoryView.bottomPadding)
    }
    
    private func addActionView(view: UIView, bottomPadding: CGFloat = 0){
        self.subviews.forEach({$0.removeFromSuperview()})
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: bottomPadding)
        ])
    }
    
    private func addButton() {
        self.addSubview(self.tapButton)
        NSLayoutConstraint.activate([
            tapButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tapButton.topAnchor.constraint(equalTo: self.topAnchor),
            tapButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    private func getContentText(message: MKReplyMessageType){
        switch message.kind {
        case .text(let text), .emoji(let text):
            self.addActionReplyTextView(text: text)
//        case .attributedText(let text):
//            self.contentLabel.isHidden = false
//            self.contentLabel.attributedText = text
        case .photo(let photo):
            self.addActionReplyMediaView(text: "Hình ảnh", image: photo.image)
        case .video(let video):
            self.addActionReplyMediaView(text: "Video", image: video.image)
        default:
            break
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
