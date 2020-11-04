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
import InputBarAccessoryView

final class MessageSubviewViewController: BasicExampleViewController {

    override var inputAccessoryView: UIView? {
        return nil
    }
    private var keyboardManager = KeyboardManager()

    private let subviewInputBar = InputBarAccessoryView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        subviewInputBar.delegate = self
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Take into account the height of the bottom input bar
        additionalBottomInset = 48
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        parent?.view.addSubview(subviewInputBar)
//        self.setupConstraints()
        keyboardManager.bind(inputAccessoryView: subviewInputBar)
        keyboardManager.bind(to: self.messagesCollectionView)
    }
    
//    override func setupConstraints() {
//        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let top = messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
//        let leading = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
//        let trailing = messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        
//        if #available(iOS 11.0, *) {
//            bottom = messagesCollectionView.bottomAnchor.constraint(equalTo: subviewInputBar.topAnchor)
//        } else {
//            bottom = messagesCollectionView.bottomAnchor.constraint(equalTo: subviewInputBar.topAnchor, constant: 0)
//        }
//        NSLayoutConstraint.activate([top, bottom, trailing, leading])
//        
//    }

    override func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(subviewInputBar)
    }
//    override func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
//        self.bottom.constant = -size.height
//        self.messagesCollectionView.scrollToBottom()
//    }
    
}
