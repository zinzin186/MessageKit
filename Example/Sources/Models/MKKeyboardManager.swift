//
//  MKKeyboardManager.swift
//  ChatExample
//
//  Created by Gapo on 28/11/2020.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit

import UIKit
import InputBarAccessoryView
import MessageKit

class MKKeyboardManager: NSObject, UIGestureRecognizerDelegate {
    
    weak var inputAccessoryView: UIView!
    var keyboardTracker: KeyboardTracker!
    var inputContainerBottomConstraint: NSLayoutConstraint!
    weak var keyboardEventsHandler: KeyboardEventsHandling?
    var notificationCenter = NotificationCenter.default
    var isAdjustingInputContainer: Bool = false
    weak var viewController: UIViewController!
    weak var collectionView: UICollectionView!
    
    private var previousBoundsUsedForInsetsAdjustment: CGRect? = nil
    
    private var inputContainerBottomBaseOffset: CGFloat = 0 {
        didSet { self.updateInputContainerBottomConstraint() }
    }

    private var inputContainerBottomAdditionalOffset: CGFloat = 0 {
        didSet { self.updateInputContainerBottomConstraint() }
    }
    
    public var layoutConfiguration: ChatLayoutConfigurationProtocol = ChatLayoutConfiguration.defaultConfiguration {
        didSet {
            self.adjustCollectionViewInsets(shouldUpdateContentOffset: false)
        }
    }
    public var placeMessagesFromBottom = false {
        didSet {
            self.adjustCollectionViewInsets(shouldUpdateContentOffset: false)
        }
    }

    @discardableResult
    func bind(inputAccessoryView: UIView, in viewController: UIViewController) -> Self {
        
        guard let superview = inputAccessoryView.superview else {
            fatalError("`inputAccessoryView` must have a superview")
        }
        self.inputAccessoryView = inputAccessoryView
        self.viewController = viewController
        superview.addConstraint(NSLayoutConstraint(item: inputAccessoryView, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: superview, attribute: .top, multiplier: 1, constant: 0))
        let leadingAnchor: NSLayoutXAxisAnchor
        let trailingAnchor: NSLayoutXAxisAnchor
        if #available(iOS 11.0, *) {
            let guide = superview.safeAreaLayoutGuide
            leadingAnchor = guide.leadingAnchor
            trailingAnchor = guide.trailingAnchor
        } else {
            leadingAnchor = superview.leadingAnchor
            trailingAnchor = superview.trailingAnchor
        }

        NSLayoutConstraint.activate([
            inputAccessoryView.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputAccessoryView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        self.inputContainerBottomConstraint = NSLayoutConstraint(item: superview, attribute: .bottom, relatedBy: .equal, toItem: inputAccessoryView, attribute: .bottom, multiplier: 1, constant: 0)
        superview.addConstraint(self.inputContainerBottomConstraint)
        
        
        return self
    }
    
    /// Adds a `UIPanGestureRecognizer` to the `scrollView` to enable interactive dismissal`
    ///
    /// - Parameter scrollView: UIScrollView
    /// - Returns: Self
    @discardableResult
    func bind(to collectionView: UICollectionView) -> Self {
        self.collectionView = collectionView
        return self
    }
    
    func setupKeyboardTracker() {
        let heightBlock = { [weak self] (bottomMargin: CGFloat, keyboardStatus: KeyboardStatus) in
            guard let sSelf = self else { return }
            if let keyboardObservingDelegate = sSelf.keyboardEventsHandler {
                keyboardObservingDelegate.onKeyboardStateDidChange(bottomMargin, keyboardStatus)
            } else {
                sSelf.changeInputContentBottomMarginTo(bottomMargin)
            }
        }
        self.keyboardTracker = KeyboardTracker(viewController: self.viewController, inputBarContainer: self.inputAccessoryView!, heightBlock: heightBlock, notificationCenter: self.notificationCenter)

        (self.viewController.view as? BaseChatViewControllerViewProtocol)?.bmaInputAccessoryView = self.keyboardTracker?.trackingView
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
                animations: { self.viewController.view.layoutIfNeeded() },
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
                animations: { self.viewController.view.layoutIfNeeded() },
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
        self.viewController.view.layoutIfNeeded()
        callback?()
        self.isAdjustingInputContainer = false
    }
    
    func adjustCollectionViewInsets(shouldUpdateContentOffset: Bool) {
        let isInteracting = collectionView.panGestureRecognizer.numberOfTouches > 0
        let isBouncingAtTop = isInteracting && collectionView.contentOffset.y < -collectionView.contentInset.top
        if !self.placeMessagesFromBottom && isBouncingAtTop { return }

        let inputHeightWithKeyboard = self.viewController.view.bounds.height - self.inputAccessoryView.frame.minY
        let newInsetBottom = self.layoutConfiguration.contentInsets.bottom + inputHeightWithKeyboard
        let insetBottomDiff = newInsetBottom - collectionView.contentInset.bottom
        var newInsetTop = self.viewController.topLayoutGuide.length + self.layoutConfiguration.contentInsets.top
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
            currentInsets.top = self.viewController.topLayoutGuide.length + self.layoutConfiguration.scrollIndicatorInsets.top
            return currentInsets
        }())

        guard shouldUpdateContentOffset else { return }

        let inputIsAtBottom = self.viewController.view.bounds.maxY - self.inputAccessoryView.frame.maxY <= 0
        if isInteracting && (needToPlaceMessagesAtBottom || needToUpdateContentInset) {
            collectionView.contentOffset.y = prevContentOffsetY
        } else if self.allContentFits {
            collectionView.contentOffset.y = -collectionView.contentInset.top
        } else if !isInteracting || inputIsAtBottom {
            collectionView.contentOffset.y = newContentOffsetY
        }
    }
    
    private func updateInputContainerBottomConstraint() {
        self.inputContainerBottomConstraint.constant = max(self.inputContainerBottomBaseOffset, self.inputContainerBottomAdditionalOffset)
        self.viewController.view.setNeedsLayout()
    }

    public var allContentFits: Bool {
        let inputHeightWithKeyboard = self.viewController.view.bounds.height - self.inputAccessoryView.frame.minY
        let insetTop = self.viewController.topLayoutGuide.length + self.layoutConfiguration.contentInsets.top
        let insetBottom = self.layoutConfiguration.contentInsets.bottom + inputHeightWithKeyboard
        let availableHeight = collectionView.bounds.height - (insetTop + insetBottom)
        let contentSize = collectionView.collectionViewLayout.collectionViewContentSize
        return availableHeight >= contentSize.height
    }
    
    func updateInputContainerBottomBaseOffset() {
        if #available(iOS 11.0, *) {
            let offset = self.viewController.bottomLayoutGuide.length
            if self.inputContainerBottomBaseOffset != offset {
                self.inputContainerBottomBaseOffset = offset
            }
        } else {
            // If we have been pushed on nav controller and hidesBottomBarWhenPushed = true, then ignore bottomLayoutMargin
            // because it has incorrect value when we actually have a bottom bar (tabbar)
            // Also if instance of BaseChatViewController is added as childViewController to another view controller, we had to check all this stuf on parent instance instead of self
            // UPD: Fixed in iOS 11.0
            let navigatedController: UIViewController
            if let parent = self.viewController.parent, !(parent is UINavigationController || parent is UITabBarController) {
                navigatedController = parent
            } else {
                navigatedController = self.viewController
            }

            if navigatedController.hidesBottomBarWhenPushed && (viewController.navigationController?.viewControllers.count ?? 0) > 1 && viewController.navigationController?.viewControllers.last == navigatedController {
                self.inputContainerBottomBaseOffset = 0
            } else {
                self.inputContainerBottomBaseOffset = self.viewController.bottomLayoutGuide.length
            }
        }
    }

}
