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


final class MessageSubviewViewController: BasicExampleViewController, InputPositionControlling {
    public var keyboardStatus: KeyboardStatus {
        return self.keyboardTracker.keyboardStatus
    }
    
    public var maximumInputSize: CGSize {
        return self.view.bounds.size
    }
    
    public var inputContentBottomMargin: CGFloat {
        return self.inputContainerBottomConstraint.constant
    }
    
    override var inputAccessoryView: UIView? {
        return nil
    }

    var unfinishedBatchUpdatesCount: Int = 0
    var onAllBatchUpdatesFinished: (() -> Void)?
    weak var scrollViewEventsHandler: ScrollViewEventsHandling?
    var inputContainerBottomConstraint: NSLayoutConstraint!
    public private(set) var inputBarContainer: UIView!
    public private(set) var inputContentContainer: UIView!
    public weak var keyboardEventsHandler: KeyboardEventsHandling?
//    open lazy var messageInputBar = InputBarAccessoryView()
    var keyboardManager = GPKeyboardManager()
    
    public var placeMessagesFromBottom = false {
        didSet {
            self.adjustCollectionViewInsets(shouldUpdateContentOffset: false)
        }
    }
    
    public var layoutConfiguration: ChatLayoutConfigurationProtocol = ChatLayoutConfiguration.defaultConfiguration {
        didSet {
            self.adjustCollectionViewInsets(shouldUpdateContentOffset: false)
        }
    }
    public var substitutesMainViewAutomatically = true
    private var previousBoundsUsedForInsetsAdjustment: CGRect? = nil
    public override func loadView() {
        if substitutesMainViewAutomatically {
            self.view = BaseChatViewControllerView() // http://stackoverflow.com/questions/24596031/uiviewcontroller-with-inputaccessoryview-is-not-deallocated
//            self.view.frame = UIScreen.main.bounds
            self.view.backgroundColor = UIColor.white
        } else {
            super.loadView()
        }

    }
    var bmaInputAccessoryView: UIView? {
        let inputBarView = InputBarAccessoryView()
        inputBarView.translatesAutoresizingMaskIntoConstraints = false
        return inputBarView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCollectionView()
        self.addInputBarContainer()
        self.addInputView()
        self.addInputContentContainer()
        self.setupKeyboardTracker()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.keyboardTracker.startTracking()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.keyboardTracker?.stopTracking()
    }
    
    private func addCollectionView() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
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
        self.inputBarContainer = UIView(frame: CGRect.zero)
        self.inputBarContainer.autoresizingMask = UIView.AutoresizingMask()
        self.inputBarContainer.translatesAutoresizingMaskIntoConstraints = false
        self.inputBarContainer.backgroundColor = .red
        self.view.addSubview(self.inputBarContainer)
        self.view.addConstraint(NSLayoutConstraint(item: self.inputBarContainer, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0))
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
            self.inputBarContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.inputBarContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        self.inputContainerBottomConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.inputBarContainer, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraint(self.inputContainerBottomConstraint)
    }

    private func addInputView() {
        let inputView = self.createChatInputView()
        inputView.backgroundColor = .yellow
        self.inputBarContainer.addSubview(inputView)
        self.inputBarContainer.addConstraint(NSLayoutConstraint(item: self.inputBarContainer, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1, constant: 0))
        self.inputBarContainer.addConstraint(NSLayoutConstraint(item: self.inputBarContainer, attribute: .bottom, relatedBy: .equal, toItem: inputView, attribute: .bottom, multiplier: 1, constant: 0))
        self.inputBarContainer.addConstraint(NSLayoutConstraint(item: self.inputBarContainer, attribute: .leading, relatedBy: .equal, toItem: inputView, attribute: .leading, multiplier: 1, constant: 0))
        self.inputBarContainer.addConstraint(NSLayoutConstraint(item: self.inputBarContainer, attribute: .trailing, relatedBy: .equal, toItem: inputView, attribute: .trailing, multiplier: 1, constant: 0))
    }

    private func addInputContentContainer() {
        self.inputContentContainer = UIView(frame: CGRect.zero)
        self.inputContentContainer.autoresizingMask = UIView.AutoresizingMask()
        self.inputContentContainer.translatesAutoresizingMaskIntoConstraints = false
        self.inputContentContainer.backgroundColor = .blue
        self.view.addSubview(self.inputContentContainer)
        self.view.addConstraint(NSLayoutConstraint(item: self.inputContentContainer, attribute: .top, relatedBy: .equal, toItem: self.inputBarContainer, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .leading, relatedBy: .equal, toItem: self.inputContentContainer, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .trailing, relatedBy: .equal, toItem: self.inputContentContainer, attribute: .trailing, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: self.inputContentContainer, attribute: .bottom, multiplier: 1, constant: 0))
    }

    private func updateInputContainerBottomBaseOffset() {
        if #available(iOS 11.0, *) {
            let offset = self.bottomLayoutGuide.length
            if self.inputContainerBottomBaseOffset != offset {
                self.inputContainerBottomBaseOffset = offset
            }
        } else {
            // If we have been pushed on nav controller and hidesBottomBarWhenPushed = true, then ignore bottomLayoutMargin
            // because it has incorrect value when we actually have a bottom bar (tabbar)
            // Also if instance of BaseChatViewController is added as childViewController to another view controller, we had to check all this stuf on parent instance instead of self
            // UPD: Fixed in iOS 11.0
            let navigatedController: UIViewController
            if let parent = self.parent, !(parent is UINavigationController || parent is UITabBarController) {
                navigatedController = parent
            } else {
                navigatedController = self
            }

            if navigatedController.hidesBottomBarWhenPushed && (navigationController?.viewControllers.count ?? 0) > 1 && navigationController?.viewControllers.last == navigatedController {
                self.inputContainerBottomBaseOffset = 0
            } else {
                self.inputContainerBottomBaseOffset = self.bottomLayoutGuide.length
            }
        }
    }

    private var inputContainerBottomBaseOffset: CGFloat = 0 {
        didSet { self.updateInputContainerBottomConstraint() }
    }

    private var inputContainerBottomAdditionalOffset: CGFloat = 0 {
        didSet { self.updateInputContainerBottomConstraint() }
    }

    private func updateInputContainerBottomConstraint() {
        self.inputContainerBottomConstraint.constant = max(self.inputContainerBottomBaseOffset, self.inputContainerBottomAdditionalOffset)
        self.view.setNeedsLayout()
    }

    var isAdjustingInputContainer: Bool = false

    public func setupKeyboardTracker() {
        let heightBlock = { [weak self] (bottomMargin: CGFloat, keyboardStatus: KeyboardStatus) in
            guard let sSelf = self else { return }
            if let keyboardObservingDelegate = sSelf.keyboardEventsHandler {
                keyboardObservingDelegate.onKeyboardStateDidChange(bottomMargin, keyboardStatus)
            } else {
                sSelf.changeInputContentBottomMarginTo(bottomMargin)
            }
        }
        self.keyboardTracker = KeyboardTracker(viewController: self, inputBarContainer: self.inputBarContainer, heightBlock: heightBlock, notificationCenter: self.notificationCenter)

        (self.view as? BaseChatViewControllerViewProtocol)?.bmaInputAccessoryView = self.keyboardTracker?.trackingView
    }

    var notificationCenter = NotificationCenter.default
    var keyboardTracker: KeyboardTracker!

    public private(set) var isFirstLayout: Bool = true
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.adjustCollectionViewInsets(shouldUpdateContentOffset: true)
        self.keyboardTracker.adjustTrackingViewSizeIfNeeded()

        if self.isFirstLayout {
            self.isFirstLayout = false
        }

        self.updateInputContainerBottomBaseOffset()
    }

    public func createChatInputView() -> UIView {
//        assert(false, "Override in subclass")
//        return UIView()
        let inputBarView = InputBarAccessoryView()
        self.scrollViewEventsHandler = inputBarView as! ScrollViewEventsHandling
        inputBarView.translatesAutoresizingMaskIntoConstraints = false
        return inputBarView
    }
    
    public func changeInputContentBottomMarginTo(_ newValue: CGFloat, animated: Bool = false, callback: (() -> Void)? = nil) {
        self.changeInputContentBottomMarginTo(newValue, animated: animated, duration: CATransaction.animationDuration(), callback: callback)
    }
    
    public func changeInputContentBottomMarginTo(_ newValue: CGFloat, animated: Bool = false, duration: CFTimeInterval, initialSpringVelocity: CGFloat = 0.0, callback: (() -> Void)? = nil) {
        guard self.inputContainerBottomConstraint.constant != newValue else { callback?(); return }
        if animated {
            self.isAdjustingInputContainer = true
            self.inputContainerBottomAdditionalOffset = newValue
            CATransaction.begin()
            UIView.animate(
                withDuration: duration,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: initialSpringVelocity,
                options: .curveLinear,
                animations: { self.view.layoutIfNeeded() },
                completion: { _ in })
            CATransaction.setCompletionBlock(callback) // this callback is guaranteed to be called
            CATransaction.commit()
            self.isAdjustingInputContainer = false
        } else {
            self.changeInputContentBottomMarginWithoutAnimationTo(newValue, callback: callback)
        }
    }
    
    public func changeInputContentBottomMarginTo(_ newValue: CGFloat, animated: Bool = false, duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, callback: (() -> Void)? = nil) {
        guard self.inputContainerBottomConstraint.constant != newValue else { callback?(); return }
        if animated {
            self.isAdjustingInputContainer = true
            CATransaction.begin()
            CATransaction.setAnimationTimingFunction(timingFunction)
            self.inputContainerBottomAdditionalOffset = newValue
            UIView.animate(
                withDuration: duration,
                animations: { self.view.layoutIfNeeded() },
                completion: { _ in }
            )
            CATransaction.setCompletionBlock(callback) // this callback is guaranteed to be called
            CATransaction.commit()
            self.isAdjustingInputContainer = false
        } else {
            self.changeInputContentBottomMarginWithoutAnimationTo(newValue, callback: callback)
        }
    }
    
    private func changeInputContentBottomMarginWithoutAnimationTo(_ newValue: CGFloat, callback: (() -> Void)?) {
        self.isAdjustingInputContainer = true
        self.inputContainerBottomAdditionalOffset = newValue
        self.view.layoutIfNeeded()
        callback?()
        self.isAdjustingInputContainer = false
    }
    func adjustCollectionViewInsets(shouldUpdateContentOffset: Bool) {
        let collectionView = messagesCollectionView
        let isInteracting = collectionView.panGestureRecognizer.numberOfTouches > 0
        let isBouncingAtTop = isInteracting && collectionView.contentOffset.y < -collectionView.contentInset.top
        if !self.placeMessagesFromBottom && isBouncingAtTop { return }

        let inputHeightWithKeyboard = self.view.bounds.height - self.inputBarContainer.frame.minY
        let newInsetBottom = self.layoutConfiguration.contentInsets.bottom + inputHeightWithKeyboard
        let insetBottomDiff = newInsetBottom - collectionView.contentInset.bottom
        var newInsetTop = self.topLayoutGuide.length + self.layoutConfiguration.contentInsets.top
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize

        let needToPlaceMessagesAtBottom = self.placeMessagesFromBottom && self.allContentFits
        if needToPlaceMessagesAtBottom {
            let realContentHeight = contentSize.height + newInsetTop + newInsetBottom
            newInsetTop += collectionView.bounds.height - realContentHeight
        }

        let insetTopDiff = newInsetTop - collectionView.contentInset.top
        let needToUpdateContentInset = self.placeMessagesFromBottom && (insetTopDiff != 0 || insetBottomDiff != 0)

        let prevContentOffsetY = collectionView.contentOffset.y

        let boundsHeightDiff: CGFloat = {
            guard shouldUpdateContentOffset, let lastUsedBounds = self.previousBoundsUsedForInsetsAdjustment else {
                return 0
            }
            let diff = lastUsedBounds.height - collectionView.bounds.height
            // When collectionView is scrolled to bottom and height increases,
            // collectionView adjusts its contentOffset automatically
            let isScrolledToBottom = contentSize.height <= collectionView.bounds.maxY - collectionView.contentInset.bottom
            return isScrolledToBottom ? max(0, diff) : diff
        }()
        self.previousBoundsUsedForInsetsAdjustment = collectionView.bounds

        let newContentOffsetY: CGFloat = {
            let minOffset = -newInsetTop
            let maxOffset = contentSize.height - (collectionView.bounds.height - newInsetBottom)
            let targetOffset = prevContentOffsetY + insetBottomDiff + boundsHeightDiff
            return max(min(maxOffset, targetOffset), minOffset)
        }()

        collectionView.contentInset = {
            var currentInsets = collectionView.contentInset
            currentInsets.bottom = newInsetBottom
            currentInsets.top = newInsetTop
            return currentInsets
        }()

        collectionView.chatto_setVerticalScrollIndicatorInsets({
            var currentInsets = collectionView.scrollIndicatorInsets
            currentInsets.bottom = self.layoutConfiguration.scrollIndicatorInsets.bottom + inputHeightWithKeyboard
            currentInsets.top = self.topLayoutGuide.length + self.layoutConfiguration.scrollIndicatorInsets.top
            return currentInsets
        }())

        guard shouldUpdateContentOffset else { return }

        let inputIsAtBottom = self.view.bounds.maxY - self.inputBarContainer.frame.maxY <= 0
        if isInteracting && (needToPlaceMessagesAtBottom || needToUpdateContentInset) {
            collectionView.contentOffset.y = prevContentOffsetY
        } else if self.allContentFits {
            collectionView.contentOffset.y = -collectionView.contentInset.top
        } else if !isInteracting || inputIsAtBottom {
            collectionView.contentOffset.y = newContentOffsetY
        }
    }

    public var allContentFits: Bool {
        let collectionView = self.messagesCollectionView
        let inputHeightWithKeyboard = self.view.bounds.height - self.inputBarContainer.frame.minY
        let insetTop = self.topLayoutGuide.length + self.layoutConfiguration.contentInsets.top
        let insetBottom = self.layoutConfiguration.contentInsets.bottom + inputHeightWithKeyboard
        let availableHeight = collectionView.bounds.height - (insetTop + insetBottom)
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        return availableHeight >= contentSize.height
    }
}
