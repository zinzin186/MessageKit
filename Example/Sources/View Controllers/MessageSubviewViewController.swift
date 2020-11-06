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

    var notificationCenter = NotificationCenter.default
    var keyboardTracker: KeyboardTracker!
    weak var keyboardEventsHandler: KeyboardEventsHandling?
    //////////
    
    override var inputAccessoryView: UIView? {
        return nil
    }
    private var keyboardManager = GPKeyboardManager()

    private let subviewInputBar = InputBarAccessoryView()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.subInput = subviewInputBar
        subviewInputBar.delegate = self
        self.view.addSubview(subviewInputBar)
        //        self.setupConstraints()
                keyboardManager.bind(inputAccessoryView: subviewInputBar)
                keyboardManager.bind(to: self.messagesCollectionView)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        // Take into account the height of the bottom input bar
        additionalBottomInset = 0
        setupConstraintsCV()
//        messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: subviewInputBar.topAnchor, constant: -90)
    }

    func setupConstraintsCV() {
            messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
            
            let top = messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 84)
            let leading = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            let trailing = messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    //        let bottom: NSLayoutConstraint
//            if #available(iOS 11.0, *) {
//                if isSubView{
//                    messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
//                }else{
//                    messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//                }
//            } else {
//                messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            }
        messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: subviewInputBar.topAnchor)
            NSLayoutConstraint.activate([top, messagesCollectionViewBottomConstraint!, trailing, leading])
            
        }


    override func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(subviewInputBar)
    }
    var currentChange: CGFloat = 55
    override func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        let paddingChange = size.height - currentChange
        let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + paddingChange)
        messagesCollectionView.setContentOffset(contentOffset, animated: false)
        currentChange = size.height
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.keyboardManager.isWillDisAppear = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardManager.isWillDisAppear = false
    }
    
}

extension MessageSubviewViewController {
    func setupKeyboardTracker() {
        let heightBlock = { [weak self] (bottomMargin: CGFloat, keyboardStatus: KeyboardStatus) in
            guard let sSelf = self else { return }
            if let keyboardObservingDelegate = sSelf.keyboardEventsHandler {
                keyboardObservingDelegate.onKeyboardStateDidChange(bottomMargin, keyboardStatus)
            } else {
                sSelf.changeInputContentBottomMarginTo(bottomMargin)
            }
        }
        self.keyboardTracker = KeyboardTracker(viewController: self, inputBarContainer: self.subviewInputBar, heightBlock: heightBlock, notificationCenter: self.notificationCenter)

        (self.view as? BaseChatViewControllerViewProtocol)?.bmaInputAccessoryView = self.keyboardTracker?.trackingView
    }
    
    func changeInputContentBottomMarginTo(_ newValue: CGFloat, animated: Bool = false, callback: (() -> Void)? = nil) {
        self.changeInputContentBottomMarginTo(newValue, animated: animated, callback: callback)
    }
}
public protocol BaseChatViewControllerViewProtocol: class {
    var bmaInputAccessoryView: UIView? { get set }
}
