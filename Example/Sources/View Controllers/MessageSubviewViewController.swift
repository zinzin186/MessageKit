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
    private var keyboardManager = MKKeyboardManager()
//
    
    lazy var subviewInputBar: InputBarAccessoryView = {
        let inputView = InputBarAccessoryView()
        inputView.translatesAutoresizingMaskIntoConstraints = false
        inputView.delegate = self
        return inputView
    }()
    
   
    public private(set) var inputContentContainer: UIView!
    var isFocusHideKeyboard: Bool = false
   
    public var substitutesMainViewAutomatically = true
    
    override func loadView() {
        if substitutesMainViewAutomatically {
            self.view = BaseChatViewControllerView()
            // http://stackoverflow.com/questions/24596031/uiviewcontroller-with-inputaccessoryview-is-not-deallocated
            self.view.backgroundColor = UIColor.black
        } else {
            super.loadView()
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCollectionView()
        self.addInputBarContainer()
        keyboardManager.bind(to: messagesCollectionView)
        self.addInputContentContainer()
        keyboardManager.setupKeyboardTracker()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardManager.keyboardTracker.startTracking()
        if self.isFocusHideKeyboard {
            isFocusHideKeyboard = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardManager.keyboardTracker?.stopTracking()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        keyboardManager.adjustCollectionViewInsets(shouldUpdateContentOffset: true)
        keyboardManager.keyboardTracker.adjustTrackingViewSizeIfNeeded()

        if self.isFirstLayout {
            self.isFirstLayout = false
        }

        keyboardManager.updateInputContainerBottomBaseOffset()
    }

    override func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(subviewInputBar)
    }


}

extension MessageSubviewViewController {
    
    private func addCollectionView() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        messagesCollectionView.keyboardDismissMode = .interactive
        let collectionView = messagesCollectionView
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0))

        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        if #available(iOS 11.0, *) {
            let guide = self.view.safeAreaLayoutGuide
            leadingAnchor = guide.leadingAnchor
            trailingAnchor = guide.trailingAnchor
        } else {
            leadingAnchor = self.view.leadingAnchor
            trailingAnchor = self.view.trailingAnchor
        }

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        collectionView.chatto_setContentInsetAdjustment(enabled: false, in: self)
        collectionView.chatto_setAutomaticallyAdjustsScrollIndicatorInsets(false)
        collectionView.chatto_setIsPrefetchingEnabled(false)
        
    }
        
    private func addInputBarContainer() {
        self.view.addSubview(self.subviewInputBar)
        keyboardManager.bind(inputAccessoryView: self.subviewInputBar, in: self)
    }

    private func addInputContentContainer() {
        self.inputContentContainer = UIView(frame: CGRect.zero)
        self.inputContentContainer.autoresizingMask = UIView.AutoresizingMask()
        self.inputContentContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.inputContentContainer)
        self.view.addConstraint(NSLayoutConstraint(item: self.inputContentContainer, attribute: .top, relatedBy: .equal, toItem: self.subviewInputBar, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.inputContentContainer, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.inputContentContainer, attribute: .trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.inputContentContainer, attribute: .bottom, multiplier: 1, constant: 0))
    }


    
}
