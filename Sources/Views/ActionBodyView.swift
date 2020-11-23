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
        return button
    }()
    @objc private func tapReplyMessage(){
        self.clickReplyMessageCallback?()
    }
    
    open var actionRemoveMessageView: ActionRemoveMessageView?
    open var actionReplyTextView: ActionReplyTextView?
    open var actionReplyMediaView: ActionReplyMediaView?
    open var actionChatFromStoryView: ActionChatFromStoryView?

    init() {
        super.init(frame: .zero)
    }

    func applyUI(isOutgoingMessage: Bool, message: MKMessageType, attributedText: NSAttributedString?){
        switch message.action {
        case .reply(let replyMessage):
            self.setupContent(message: replyMessage, attributedText: attributedText)
        case .story:
            self.addActionChatFromStoryView(image: nil)
        case .remove:
            self.addActionRemoveMessageView(attributedText: attributedText)
        default:
            break
        }
    }
    
    func addActionRemoveMessageView(attributedText: NSAttributedString?){
        self.actionRemoveMessageView = ActionRemoveMessageView(frame: CGRect(0, 0, self.bounds.width, self.bounds.height + MKMessageConstant.ActionView.RemoveView.bottomPadding))
        self.actionRemoveMessageView?.contentLabel.attributedText = attributedText
        self.addActionView(view: self.actionRemoveMessageView!)
        
    }
   
    func addActionReplyTextView(attributedText: NSAttributedString?){
        self.actionReplyTextView = ActionReplyTextView(frame: CGRect(0, 0, self.bounds.width, self.bounds.height + MKMessageConstant.ActionView.ReplyView.bottomPadding))
        self.actionReplyTextView?.contentLabel.attributedText = attributedText
        self.addActionView(view: self.actionReplyTextView!)
        addButton()
        
    }
    func addActionReplyMediaView(attributedText: NSAttributedString?, medias: [String]){
        self.actionReplyMediaView = ActionReplyMediaView(frame: CGRect(0, 0, self.bounds.width, self.bounds.height + MKMessageConstant.ActionView.ReplyView.bottomPadding))
        self.actionReplyMediaView?.messageLabel.attributedText = attributedText
        self.addActionView(view: self.actionReplyMediaView!)
        addButton()
    }
    
    func addActionChatFromStoryView(image: UIImage?){
        self.actionChatFromStoryView = ActionChatFromStoryView(frame: CGRect(0, 0, self.bounds.width, self.bounds.height + MKMessageConstant.ActionView.StoryView.bottomPadding))
        self.actionChatFromStoryView?.imageView.image = image
        self.addActionView(view: self.actionChatFromStoryView!)
        addButton()
    }
    
    private func addActionView(view: UIView){
        self.subviews.forEach({$0.removeFromSuperview()})
        self.addSubview(view)
    }
    
    private func addButton() {
        self.addSubview(self.tapButton)
        tapButton.frame = self.bounds
    }
    private func setupContent(message: MKReplyMessageType, attributedText: NSAttributedString?){
        if let medias = message.medias, !message.deleted {
            self.addActionReplyMediaView(attributedText: attributedText, medias: medias)
        } else {
            self.addActionReplyTextView(attributedText: attributedText)
        }

    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
