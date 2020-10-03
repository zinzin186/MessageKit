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

open class ReplyBodyView: UIView {
    
    private lazy var tapButton: UIButton = { [unowned self] in
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(self.tapReplyMessage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    @objc private func tapReplyMessage(){
        print("Tapppp")
    }
    
    lazy var imageView: UIImageView = {[unowned self] in
        let imageView: UIImageView = .init()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25)
        ])
        addSubview(teaserLabel)
        NSLayoutConstraint.activate([
            teaserLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 5),
            teaserLabel.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 5),
            teaserLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
        ])
        addSubview(tapButton)
        NSLayoutConstraint.activate([
            tapButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tapButton.topAnchor.constraint(equalTo: self.topAnchor),
            tapButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        return imageView
    }()
    private lazy var contentLabel: UILabel = {[unowned self] in
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -25)
        ])
        NSLayoutConstraint.activate([
            tapButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tapButton.topAnchor.constraint(equalTo: self.topAnchor),
            tapButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        return label
    }()
    lazy var teaserLabel: UILabel = {
        let label: UILabel = .init()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init() {
        super.init(frame: .zero)
        
        
        
        
        
    }

    func applyUI(isOutgoingMessage: Bool, message: MKMessageType){
        if case ActionType.reply(let replyMessage) = message.action {
            self.getContentText(message: replyMessage)
        }
        
    }
    
    
    private func getContentText(message: MKReplyMessageType){
        switch message.kind {
        case .text(let text), .emoji(let text):
            self.contentLabel.text = text
        case .attributedText(let text):
            self.contentLabel.attributedText = text
        case .photo(let photo):
            self.imageView.image = photo.image ?? photo.placeholderImage
            teaserLabel.text = "Hình ảnh"
        case .video(let video):
            self.imageView.image = video.image ?? video.placeholderImage
            teaserLabel.text = "Video"
        default:
            break
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
