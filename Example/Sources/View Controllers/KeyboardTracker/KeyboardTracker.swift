//
//  KeyboardTracker.swift
//  ChatExample
//
//  Created by Gapo on 11/7/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit

public enum KeyboardStatus {
    case hiding
    case hidden
    case showing
    case shown
}

public typealias KeyboardHeightBlock = (_ height: CGFloat, _ status: KeyboardStatus) -> Void

class KeyboardTracker {
    private(set) var keyboardStatus: KeyboardStatus = .hidden
    private let view: UIView
    var trackingView: UIView {
        return self.keyboardTrackerView
    }
    private lazy var keyboardTrackerView: KeyboardTrackingView = {
        let trackingView = KeyboardTrackingView()
        trackingView.positionChangedCallback = { [weak self] in
            guard let sSelf = self else { return }
            if !sSelf.isPerformingForcedLayout {
                sSelf.layoutInputAtTrackingViewIfNeeded()
            }
        }
        return trackingView
    }()

    var isTracking = false
    var inputBarContainer: UIView
    private var notificationCenter: NotificationCenter

    private var heightBlock: KeyboardHeightBlock

    init(viewController: UIViewController, inputBarContainer: UIView, heightBlock: @escaping KeyboardHeightBlock, notificationCenter: NotificationCenter) {
        self.view = viewController.view
        self.heightBlock = heightBlock
        self.inputBarContainer = inputBarContainer
        self.notificationCenter = notificationCenter
        self.notificationCenter.addObserver(
            self,
            selector: #selector(KeyboardTracker.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(KeyboardTracker.keyboardDidShow(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(KeyboardTracker.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(KeyboardTracker.keyboardDidHide(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
        self.notificationCenter.addObserver(
            self,
            selector: #selector(KeyboardTracker.keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    deinit {
        self.notificationCenter.removeObserver(self)
    }

    func startTracking() {
        self.isTracking = true
    }

    func stopTracking() {
        self.isTracking = false
    }

    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard self.isTracking else { return }
        guard !self.isPerformingForcedLayout else { return }
        let bottomConstraint = self.bottomConstraintFromNotification(notification)
        guard bottomConstraint > 0 else { return } // Some keyboards may report initial willShow/DidShow notifications with invalid positions
        self.keyboardStatus = .showing
        self.layoutInputContainer(withBottomConstraint: bottomConstraint)
    }

    @objc
    private func keyboardDidShow(_ notification: Notification) {
        guard self.isTracking else { return }
        guard !self.isPerformingForcedLayout else { return }

        let bottomConstraint = self.bottomConstraintFromNotification(notification)
        guard bottomConstraint > 0 else { return } // Some keyboards may report initial willShow/DidShow notifications with invalid positions
        self.keyboardStatus = .shown
        self.layoutInputContainer(withBottomConstraint: bottomConstraint)
        self.adjustTrackingViewSizeIfNeeded()
    }

    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard self.isTracking else { return }
        let bottomConstraint = self.bottomConstraintFromNotification(notification)
        if bottomConstraint == 0 {
            self.keyboardStatus = .hiding
            self.layoutInputAtBottom()
        }
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        guard self.isTracking else { return }
        self.keyboardStatus = .hiding
        self.layoutInputAtBottom()
    }

    @objc
    private func keyboardDidHide(_ notification: Notification) {
        guard self.isTracking else { return }
        self.keyboardStatus = .hidden
        self.layoutInputAtBottom()
    }

    private func bottomConstraintFromNotification(_ notification: Notification) -> CGFloat {
        guard let rect = ((notification as NSNotification).userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return 0 }
        guard rect.height > 0 else { return 0 }
        let rectInView = self.view.convert(rect, from: nil)
        guard rectInView.maxY >=~ self.view.bounds.height else { return 0 } // Undocked keyboard
        return max(0, self.view.bounds.height - rectInView.minY - self.keyboardTrackerView.intrinsicContentSize.height)
    }

    private func bottomConstraintFromTrackingView() -> CGFloat {
        guard self.keyboardTrackerView.superview != nil else { return 0 }
        let trackingViewRect = self.view.convert(self.keyboardTrackerView.bounds, from: self.keyboardTrackerView)
        return max(0, self.view.bounds.height - trackingViewRect.maxY)
    }

    func adjustTrackingViewSizeIfNeeded() {
        guard self.isTracking && self.keyboardStatus == .shown else { return }
        self.adjustTrackingViewSize()
    }

    private func adjustTrackingViewSize() {
        let inputContainerHeight = self.inputBarContainer.bounds.height
        if self.keyboardTrackerView.preferredSize.height != inputContainerHeight {
            self.keyboardTrackerView.preferredSize.height = inputContainerHeight
            self.isPerformingForcedLayout = true

            // Sometimes, the autolayout system doesn't finish the layout inside of the input bar container at this point.
            // If it happens, then the input bar may have a height different than an input bar container.
            // We need to ensure that their heights are the same; otherwise, it would lead to incorrect calculations that in turn affects lastKnownKeyboardHeight.
            // Tracking view adjustment changes a keyboard height and triggers an update of lastKnownKeyboardHeight.
            self.inputBarContainer.layoutIfNeeded()
            self.keyboardTrackerView.window?.layoutIfNeeded()

            self.isPerformingForcedLayout = false
        }
    }

    private func layoutInputAtBottom() {
        self.keyboardTrackerView.bounds.size.height = 0
        self.layoutInputContainer(withBottomConstraint: 0)
    }

    var isPerformingForcedLayout: Bool = false
    func layoutInputAtTrackingViewIfNeeded() {
        guard self.isTracking && self.keyboardStatus == .shown else { return }
        self.layoutInputContainer(withBottomConstraint: self.bottomConstraintFromTrackingView())
    }

    private func layoutInputContainer(withBottomConstraint constraint: CGFloat) {
        self.isPerformingForcedLayout = true
        self.heightBlock(constraint, self.keyboardStatus)
        self.isPerformingForcedLayout = false
    }
}

private class KeyboardTrackingView: UIView {

    var positionChangedCallback: (() -> Void)?
    var observedView: UIView?

    deinit {
        if let observedView = self.observedView {
            observedView.removeObserver(self, forKeyPath: "frame")
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        self.autoresizingMask = .flexibleHeight
        self.isUserInteractionEnabled = false
        self.backgroundColor = UIColor.clear
        self.isHidden = true
    }

    var preferredSize: CGSize = .zero {
        didSet {
            if oldValue != self.preferredSize {
                self.invalidateIntrinsicContentSize()
                self.window?.setNeedsLayout()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        return self.preferredSize
    }

    override func didMoveToSuperview() {
        if let observedView = self.observedView {
            observedView.removeObserver(self, forKeyPath: "center")
            self.observedView = nil
        }

        if let newSuperview = self.superview {
            newSuperview.addObserver(self, forKeyPath: "center", options: [.new, .old], context: nil)
            self.observedView = newSuperview
        }

        super.didMoveToSuperview()
    }

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        guard let object = object as? UIView, let superview = self.superview else { return }
        if object === superview {
            guard let sChange = change else { return }
            guard let oldCenter = (sChange[NSKeyValueChangeKey.oldKey] as? NSValue), let newCenter = (sChange[NSKeyValueChangeKey.newKey] as? NSValue) else {
                return
            }
            if oldCenter.cgPointValue != newCenter.cgPointValue {
                self.positionChangedCallback?()
            }
        }
    }
}

private let scale = UIScreen.main.scale

infix operator >=~
func >=~ (lhs: CGFloat, rhs: CGFloat) -> Bool {
    return round(lhs * scale) >= round(rhs * scale)
}
extension UIScrollView {
    func chatto_setContentInsetAdjustment(enabled: Bool, in viewController: UIViewController) {
        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                self.contentInsetAdjustmentBehavior = enabled ? .always : .never
            } else {
                viewController.automaticallyAdjustsScrollViewInsets = enabled
            }
        #else
            viewController.automaticallyAdjustsScrollViewInsets = enabled
        #endif
    }

    func chatto_setAutomaticallyAdjustsScrollIndicatorInsets(_ adjusts: Bool) {
        if #available(iOS 13.0, *) {
            self.automaticallyAdjustsScrollIndicatorInsets = adjusts
        }
    }

    func chatto_setVerticalScrollIndicatorInsets(_ insets: UIEdgeInsets) {
        if #available(iOS 11.1, *) {
            self.verticalScrollIndicatorInsets = insets
        } else {
            self.scrollIndicatorInsets = insets
        }
    }
}

extension UICollectionView {
    func chatto_setIsPrefetchingEnabled(_ isPrefetchingEnabled: Bool) {
        if #available(iOS 10.0, *) {
            self.isPrefetchingEnabled = isPrefetchingEnabled
        }
    }
}
