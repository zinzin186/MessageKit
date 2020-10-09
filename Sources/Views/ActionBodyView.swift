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
    
    
    
    private lazy var tapButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(self.tapReplyMessage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    @objc private func tapReplyMessage(){
        print("Tapppp")
    }
    
    var actionRemoveMessageView: ActionRemoveMessageView?
    var actionReplyTextView: ActionReplyTextView?
    var actionReplyMediaView: ActionReplyMediaView?

    init() {
        super.init(frame: .zero)
    }

    func applyUI(isOutgoingMessage: Bool, message: MKMessageType){
        switch message.action {
        case .reply(let replyMessage):
            self.getContentText(message: replyMessage)
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
        self.actionRemoveMessageView?.removeFromSuperview()
        self.actionRemoveMessageView = ActionRemoveMessageView()
        self.actionRemoveMessageView?.messageLabel.text = text
        self.addSubview(actionRemoveMessageView!)
        NSLayoutConstraint.activate([
            actionRemoveMessageView!.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            actionRemoveMessageView!.topAnchor.constraint(equalTo: self.topAnchor),
            actionRemoveMessageView!.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            actionRemoveMessageView!.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
    func addActionReplyTextView(text: String){
        self.actionReplyTextView?.removeFromSuperview()
        self.actionReplyTextView = ActionReplyTextView()
        self.actionReplyTextView?.messageLabel.text = text
        
    }
    func addActionReplyMediaView(text: String, image: UIImage?){
        self.actionReplyMediaView?.removeFromSuperview()
        self.actionReplyMediaView = ActionReplyMediaView()
        self.actionReplyMediaView?.messageLabel.text = text
        self.actionReplyMediaView?.imageView.image = image
        
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
