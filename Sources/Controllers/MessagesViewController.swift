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
import InputBarAccessoryView

/// A subclass of `UIViewController` with a `MessagesCollectionView` object
/// that is used to display conversation interfaces.
open class MessagesViewController: UIViewController,
UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate {

    /// The `MessagesCollectionView` managed by the messages view controller object.
    open var messagesCollectionView = MessagesCollectionView()

    open var subInput: UIView?
    /// The `InputBarAccessoryView` used as the `inputAccessoryView` in the view controller.
    open lazy var messageInputBar = InputBarAccessoryView()

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// last item whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    /// NOTE: This is related to `scrollToLastItem` whereas the below flag is related to `scrollToBottom` - check each function for differences
    open var scrollsToLastItemOnKeyboardBeginsEditing: Bool = false

    /// A Boolean value that determines whether the `MessagesCollectionView` scrolls to the
    /// bottom whenever the `InputTextView` begins editing.
    ///
    /// The default value of this property is `false`.
    /// NOTE: This is related to `scrollToBottom` whereas the above flag is related to `scrollToLastItem` - check each function for differences
    open var scrollsToBottomOnKeyboardBeginsEditing: Bool = false
    
    /// A Boolean value that determines whether the `MessagesCollectionView`
    /// maintains it's current position when the height of the `MessageInputBar` changes.
    ///
    /// The default value of this property is `false`.
    open var maintainPositionOnKeyboardFrameChanged: Bool = false

    /// Display the date of message by swiping left.
    /// The default value of this property is `false`.
    
    //To check keyboard show hide
    open var currentOriginYInputBar: CGFloat?
    
    open var currentKeyboardHeight: CGFloat = 0.0
    
    open var messagesCollectionViewBottomConstraint: NSLayoutConstraint?
    open var showMessageTimestampOnSwipeLeft: Bool = false {
        didSet {
            messagesCollectionView.showMessageTimestampOnSwipeLeft = showMessageTimestampOnSwipeLeft
            if showMessageTimestampOnSwipeLeft {
                addPanGesture()
            } else {
                removePanGesture()
            }
        }
    }
    open var isSubView: Bool {
        return false
    }

    /// Pan gesture for display the date of message by swiping left.
    private var panGesture: UIPanGestureRecognizer?

    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override var inputAccessoryView: UIView? {
        return messageInputBar
    }

    open override var shouldAutorotate: Bool {
        return false
    }

    /// A CGFloat value that adds to (or, if negative, subtracts from) the automatically
    /// computed value of `messagesCollectionView.contentInset.bottom`. Meant to be used
    /// as a measure of last resort when the built-in algorithm does not produce the right
    /// value for your app. Please let us know when you end up having to use this property.
    open var additionalBottomInset: CGFloat = 0 {
        didSet {
            let delta = additionalBottomInset - oldValue
            messageCollectionViewBottomInset += delta
        }
    }

    public var isTypingIndicatorHidden: Bool {
        return messagesCollectionView.isTypingIndicatorHidden
    }

    open var selectedIndexPathForMenu: IndexPath?

    open var isFirstLayout: Bool = true
    
    open var isMessagesControllerBeingDismissed: Bool = false

    open var messageCollectionViewBottomInset: CGFloat = 0 {
        didSet {
            messagesCollectionView.contentInset.bottom = messageCollectionViewBottomInset
            messagesCollectionView.scrollIndicatorInsets.bottom = messageCollectionViewBottomInset
        }
    }

    // MARK: - View Life Cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        setupSubviews()
//        setupConstraints()
        setupDelegates()
        addMenuControllerObservers()
        addObservers()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isMessagesControllerBeingDismissed = false
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isMessagesControllerBeingDismissed = true
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isMessagesControllerBeingDismissed = false
    }
    
    open override func viewDidLayoutSubviews() {
        // Hack to prevent animation of the contentInset after viewDidAppear
        if isFirstLayout {
            defer { isFirstLayout = false }
            addKeyboardObservers()
            messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
        }
    }

    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        } else {
            // Fallback on earlier versions
        }
        messageCollectionViewBottomInset = requiredInitialScrollViewBottomInset()
    }

    // MARK: - Initializers

    deinit {
        removeKeyboardObservers()
        removeMenuControllerObservers()
        removeObservers()
        clearMemoryCache()
    }

    // MARK: - Methods [Private]

    /// Display time of message by swiping the cell
    private func addPanGesture() {
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        guard let panGesture = panGesture else {
            return
        }
        panGesture.delegate = self
        messagesCollectionView.addGestureRecognizer(panGesture)
        messagesCollectionView.clipsToBounds = false
    }

    private func removePanGesture() {
        guard let panGesture = panGesture else {
            return
        }
        panGesture.delegate = nil
        self.panGesture = nil
        messagesCollectionView.removeGestureRecognizer(panGesture)
        messagesCollectionView.clipsToBounds = true
    }

    @objc
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let parentView = gesture.view else {
            return
        }

        switch gesture.state {
        case .began, .changed:
            messagesCollectionView.showsVerticalScrollIndicator = false
            let translation = gesture.translation(in: view)
            let minX = -(view.frame.size.width * 0.35)
            let maxX: CGFloat = 0
            var offsetValue = translation.x
            offsetValue = max(offsetValue, minX)
            offsetValue = min(offsetValue, maxX)
            parentView.frame.origin.x = offsetValue
        case .ended:
            messagesCollectionView.showsVerticalScrollIndicator = true
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
                parentView.frame.origin.x = 0
            }, completion: nil)
        default:
            break
        }
    }

    private func setupDefaults() {
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .collectionViewBackground
        if #available(iOS 11.0, *) {
            messagesCollectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        messagesCollectionView.keyboardDismissMode = .interactive
        messagesCollectionView.alwaysBounceVertical = true
        messagesCollectionView.backgroundColor = .collectionViewBackground
        messagesCollectionView.register(ActionMessageCell.self)
    }

    private func setupDelegates() {
        messagesCollectionView.delegate = self
        messagesCollectionView.dataSource = self
    }

    private func setupSubviews() {
        view.addSubview(messagesCollectionView)
    }

    open func setupConstraints() {
        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        let top = messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
        let leading = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailing = messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        let bottom: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            if isSubView{
                messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            }else{
                messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            }
        } else {
            messagesCollectionViewBottomConstraint = messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        }
        NSLayoutConstraint.activate([top, messagesCollectionViewBottomConstraint!, trailing, leading])
        
    }
    
    @objc
        open func handleTextViewDidBeginEditing(_ notification: Notification) {
            if scrollsToLastItemOnKeyboardBeginsEditing || scrollsToBottomOnKeyboardBeginsEditing {
                guard let inputTextView = notification.object as? InputTextView,
                    inputTextView === messageInputBar.inputTextView else { return }

                if scrollsToLastItemOnKeyboardBeginsEditing {
                    messagesCollectionView.scrollToLastItem()
                } else {
                    messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }

    @objc
    open func handleKeyboardWillShowState(_ notification: Notification) {
        self.handleKeyboardWillShow(notification)
                
    }
    
    open func handleKeyboardWillShow(_ notification: Notification) {
        guard !isMessagesControllerBeingDismissed else { return }
        
        guard let keyboardStartFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard !keyboardStartFrameInScreenCoords.isEmpty || UIDevice.current.userInterfaceIdiom != .pad else {
            // WORKAROUND for what seems to be a bug in iPad's keyboard handling in iOS 11: we receive an extra spurious frame change
            // notification when undocking the keyboard, with a zero starting frame and an incorrect end frame. The workaround is to
            // ignore this notification.
            return
        }

        guard self.presentedViewController == nil else {
            // This is important to skip notifications from child modal controllers in iOS >= 13.0
            return
    }

    guard let keyboardEndFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            let keyboardEndFrame = view.convert(keyboardEndFrameInScreenCoords, from: view.window)
            if let currentOffset = self.currentOriginYInputBar, self.subInput?.frame.origin.y == currentOffset {
    //            return
            } else {
                self.currentOriginYInputBar = self.subInput?.frame.origin.y
            }
            
            let newBottomInset = keyboardEndFrame.height - bottomInset
            let differenceOfBottomInset = newBottomInset - messageCollectionViewBottomInset
            let contentOffset = CGPoint(x: messagesCollectionView.contentOffset.x, y: messagesCollectionView.contentOffset.y + differenceOfBottomInset)
    //        messagesCollectionView.setContentOffset(contentOffset, animated: false)
            let currentOffset = messagesCollectionView.contentOffset.y
            let contentSizeHeight = messagesCollectionView.contentSize.height
            let heightCV = messagesCollectionView.frame.height
            let offset = (contentSizeHeight - heightCV) - (currentOffset + keyboardEndFrame.height)
            if contentOffset.y + heightCV <= contentSizeHeight - 1 {
                messagesCollectionView.setContentOffset(contentOffset, animated: false)
            } else {
                messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
        }
                
    }
    @objc
    open func handleKeyboardWillHideState(_ notification: Notification) {
        self.handleKeyboardWillHide(notification)
    }
    open func handleKeyboardWillHide(_ notification: Notification) {
        guard !isMessagesControllerBeingDismissed  else { return }
        
        guard let keyboardStartFrameInScreenCoords = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard !keyboardStartFrameInScreenCoords.isEmpty || UIDevice.current.userInterfaceIdiom != .pad else {
            // WORKAROUND for what seems to be a bug in iPad's keyboard handling in iOS 11: we receive an extra spurious frame change
            // notification when undocking the keyboard, with a zero starting frame and an incorrect end frame. The workaround is to
            // ignore this notification.
            return
        }

        guard self.presentedViewController == nil else {
            // This is important to skip notifications from child modal controllers in iOS >= 13.0
            return
        }
        if let currentOffset = self.currentOriginYInputBar, self.subInput?.frame.origin.y == currentOffset {
            return
        } else {
//            self.currentOriginYInputBar = self.subInput?.frame.origin.y
        }
    
    }

    // MARK: - Typing Indicator API

    /// Sets the typing indicator sate by inserting/deleting the `TypingBubbleCell`
    ///
    /// - Parameters:
    ///   - isHidden: A Boolean value that is to be the new state of the typing indicator
    ///   - animated: A Boolean value determining if the insertion is to be animated
    ///   - updates: A block of code that will be executed during `performBatchUpdates`
    ///              when `animated` is `TRUE` or before the `completion` block executes
    ///              when `animated` is `FALSE`
    ///   - completion: A completion block to execute after the insertion/deletion
    open func setTypingIndicatorViewHidden(_ isHidden: Bool, animated: Bool, whilePerforming updates: (() -> Void)? = nil, completion: ((Bool) -> Void)? = nil) {

        guard isTypingIndicatorHidden != isHidden else {
            completion?(false)
            return
        }

        let section = messagesCollectionView.numberOfSections
        messagesCollectionView.setTypingIndicatorViewHidden(isHidden)

        if animated {
            messagesCollectionView.performBatchUpdates({ [weak self] in
                self?.performUpdatesForTypingIndicatorVisability(at: section)
                updates?()
                }, completion: completion)
        } else {
            performUpdatesForTypingIndicatorVisability(at: section)
            updates?()
            completion?(true)
        }
    }

    /// Performs a delete or insert on the `MessagesCollectionView` on the provided section
    ///
    /// - Parameter section: The index to modify
    private func performUpdatesForTypingIndicatorVisability(at section: Int) {
        if isTypingIndicatorHidden {
            messagesCollectionView.deleteSections([section - 1])
        } else {
            messagesCollectionView.insertSections([section])
        }
    }

    /// A method that by default checks if the section is the last in the
    /// `messagesCollectionView` and that `isTypingIndicatorViewHidden`
    /// is FALSE
    ///
    /// - Parameter section
    /// - Returns: A Boolean indicating if the TypingIndicator should be presented at the given section
    public func isSectionReservedForTypingIndicator(_ section: Int) -> Bool {
        return !messagesCollectionView.isTypingIndicatorHidden && section == self.numberOfSections(in: messagesCollectionView) - 1
    }

    // MARK: - UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        let sections = collectionView.messagesDataSource?.numberOfSections(in: collectionView) ?? 0
        return collectionView.isTypingIndicatorHidden ? sections : sections + 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let collectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        if isSectionReservedForTypingIndicator(section) {
            return 1
        }
        return collectionView.messagesDataSource?.numberOfItems(inSection: section, in: collectionView) ?? 0
    }

    /// Notes:
    /// - If you override this method, remember to call MessagesDataSource's customCell(for:at:in:)
    /// for MessageKind.custom messages, if necessary.
    ///
    /// - If you are using the typing indicator you will need to ensure that the section is not
    /// reserved for it with `isSectionReservedForTypingIndicator` defined in
    /// `MessagesCollectionViewFlowLayout`
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }

        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }

        if isSectionReservedForTypingIndicator(indexPath.section) {
            return messagesDataSource.typingIndicator(at: indexPath, in: messagesCollectionView)
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        switch message.kind {
        case .text, .attributedText, .emoji:
            let cell = messagesCollectionView.dequeueReusableCell(TextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .photo, .video:
            let cell = messagesCollectionView.dequeueReusableCell(MediaMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .sticker:
            let cell = messagesCollectionView.dequeueReusableCell(StickerMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .location:
            let cell = messagesCollectionView.dequeueReusableCell(LocationMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .audio:
            let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .contact:
            let cell = messagesCollectionView.dequeueReusableCell(ContactMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .linkPreview:
            let cell = messagesCollectionView.dequeueReusableCell(LinkPreviewMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .action:
            let cell = messagesCollectionView.dequeueReusableCell(ActionMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .donate:
            let cell = messagesCollectionView.dequeueReusableCell(DonateMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .call:
            let cell = messagesCollectionView.dequeueReusableCell(CallMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        case .custom:
            return messagesDataSource.customCell(for: message, at: indexPath, in: messagesCollectionView)
        }
    }

    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }

        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return displayDelegate.messageHeaderView(for: indexPath, in: messagesCollectionView)
        case UICollectionView.elementKindSectionFooter:
            return displayDelegate.messageFooterView(for: indexPath, in: messagesCollectionView)
        default:
            fatalError(MessageKitError.unrecognizedSectionKind)
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let messagesFlowLayout = collectionViewLayout as? MessagesCollectionViewFlowLayout else { return .zero }
        return messagesFlowLayout.sizeForItem(at: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        if isSectionReservedForTypingIndicator(section) {
            return .zero
        }
        return layoutDelegate.headerViewSize(for: section, in: messagesCollectionView)
    }

    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? TypingIndicatorCell else { return }
        cell.typingBubble.startAnimating()
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let messagesCollectionView = collectionView as? MessagesCollectionView else {
            fatalError(MessageKitError.notMessagesCollectionView)
        }
        guard let layoutDelegate = messagesCollectionView.messagesLayoutDelegate else {
            fatalError(MessageKitError.nilMessagesLayoutDelegate)
        }
        if isSectionReservedForTypingIndicator(section) {
            return .zero
        }
        return layoutDelegate.footerViewSize(for: section, in: messagesCollectionView)
    }

    open func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return false }

        if isSectionReservedForTypingIndicator(indexPath.section) {
            return false
        }

        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        switch message.kind {
        case .text, .attributedText, .emoji, .photo:
            selectedIndexPathForMenu = indexPath
            return true
        default:
            return false
        }
    }

    open func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        if let cell = messagesCollectionView.cellForItem(at: indexPath) as? MessageContentCell{
            cell.focusWhenLongPressMessage()
        }
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return false
        }
        return (action == NSSelectorFromString("copy:"))
    }

    open func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
            fatalError(MessageKitError.nilMessagesDataSource)
        }
        let pasteBoard = UIPasteboard.general
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)

        switch message.kind {
        case .text(let text), .emoji(let text):
            pasteBoard.string = text
        case .attributedText(let attributedText):
            pasteBoard.string = attributedText.string
        case .photo(let mediaItem):
            pasteBoard.image = mediaItem.image ?? mediaItem.placeholderImage
        default:
            break
        }
    }

    // MARK: - Helpers
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(clearMemoryCache), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
    }
    
    @objc private func clearMemoryCache() {
        MessageStyle.bubbleImageCache.removeAllObjects()
    }

    // MARK: - UIGestureRecognizerDelegate

    /// check pan gesture direction
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        let velocity = panGesture.velocity(in: messagesCollectionView)
        return abs(velocity.x) > abs(velocity.y)
    }
}
