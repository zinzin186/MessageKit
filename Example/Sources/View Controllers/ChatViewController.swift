/*
MIT License

Copyright (c) 2017-2020 MessageKit

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
import MessageKit
import InputBarAccessoryView
import RxDataSources
import RxSwift
import RxCocoa
import DifferenceKit

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MKMessagesDataSource {

    enum SectionID: Differentiable, CaseIterable {
        case first, second, third
    }

    typealias Section = ArraySection<SectionID, String>
    
    
    
    
    
    // MARK: - Public properties
 var contextMenu: ContextMenu?
    /// The `BasicAudioController` controll the AVAudioPlayer state (play, pause, stop) and udpate audio cell UI accordingly.
    lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    lazy var messageList: [MockMessage] = []
    
    override var isSubView: Bool {
        return false
    }
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        return control
    }()
    var bottom: NSLayoutConstraint!
    // MARK: - Private properties

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        loadFirstMessages()
        title = "MessageKit"
        self.cvAnimatedDataSource = RxCollectionViewSectionedReloadDataSourceWithReload(configureCell: self.collectionViewDataSourceUI())
        self.dataSubject
            .bind(to: self.messagesCollectionView.rx.items(dataSource: self.cvAnimatedDataSource))
            .disposed(by: self.disposeBag)
        cvAnimatedDataSource.dataReloaded.emit(onNext: {
            print(self.messagesCollectionView.numberOfSections)
                }).disposed(by: disposeBag)
    }
    
//    override func setupConstraints() {
//        messagesCollectionView.translatesAutoresizingMaskIntoConstraints = false
//
//        let top = messagesCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
//        let leading = messagesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
//        let trailing = messagesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//
//        if #available(iOS 11.0, *) {
//            bottom = messagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        } else {
//            bottom = messagesCollectionView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 0)
//        }
//        NSLayoutConstraint.activate([top, bottom, trailing, leading])
//
//    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        MockSocket.shared.connect(with: [SampleData.shared.nathan, SampleData.shared.wu])
//            .onNewMessage { [weak self] message in
//                self?.insertMessage(message)
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        MockSocket.shared.disconnect()
        audioController.stopAnyOngoingPlaying()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    let disposeBag = DisposeBag()
    var dataSubject: BehaviorRelay<[ChatSection]> = BehaviorRelay<[ChatSection]>(value: [])
    var cvAnimatedDataSource: RxCollectionViewSectionedReloadDataSourceWithReload<ChatSection>!
    func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
            let count = UserDefaults.standard.mockMessagesCount()
            SampleData.shared.getMessages(count: count) { messages in
                DispatchQueue.main.async {
                    self.messageList = messages
                    let initialRandomizedSections = self.initialValue()
                    
                    self.dataSubject.accept(initialRandomizedSections)
                    
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
    }
    var isLoadingMore: Bool = false
    @objc func loadMoreMessages() {
        self.isLoadingMore = true
        print("Load more.......")
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) {
            SampleData.shared.getMessages(count: 20) { messages in
                DispatchQueue.main.async {
                    self.messageList.insert(contentsOf: messages, at: 0)
                    let beforeContentSize = self.messagesCollectionView.contentSize.height
                    print("beforeContentSize: \(beforeContentSize)")
                    self.messagesCollectionView.updateOffsetWhenLoadPrev()
//                    self.messageList.append(contentsOf: messages)
                    let initialRandomizedSections = self.initialValue()
                    self.dataSubject.accept(initialRandomizedSections)
                    UIView.animate(withDuration: 0) {
                        self.messagesCollectionView.performBatchUpdates(nil) { (_) in
                            let afterContentSize = self.messagesCollectionView.contentSize.height
                            print("afterContentSize: \(afterContentSize)")
                            let newOffset = CGPoint(
                                x: self.messagesCollectionView.contentOffset.x,
                                y: self.messagesCollectionView.contentOffset.y + (afterContentSize - beforeContentSize))
//                            self.messagesCollectionView.setContentOffset(newOffset, animated: false)
                        }
                    }
                    
//                    let afterContentSize = self.messagesCollectionView.contentSize.height
                    
                    self.isLoadingMore = false
//                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false

        showMessageTimestampOnSwipeLeft = true // default false
        
        messagesCollectionView.refreshControl = refreshControl
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .primaryColor
        messageInputBar.sendButton.setTitleColor(.primaryColor, for: .normal)
        messageInputBar.sendButton.setTitleColor(
            UIColor.primaryColor.withAlphaComponent(0.3),
            for: .highlighted
        )
    }
     
    private func getTitleText(isOutgoingMessage: Bool, message: MKMessageType, replyMessage: MKReplyMessageType) -> String {
        if isOutgoingMessage {
            if message.sender.senderId == replyMessage.sender.senderId {
                return "Bạn đã trả lời chính mình"
            } else {
                return "Bạn đã trả lời \(replyMessage.sender.displayName)"
            }
        }
        if message.sender.senderId == replyMessage.sender.senderId {
            return "\(message.sender.displayName) đã trả lời chính mình"
        } else {
            return "\(message.sender.displayName) đã trả lời \(replyMessage.sender.displayName)"
        }
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }

    // MARK: - MessagesDataSource

    func currentSender() -> MKSenderType {
        return SampleData.shared.currentSender
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MKMessageType {
        return messageList[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    func cellBottomLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }

    func messageTopLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
        switch message.action {
        case .reply(let replyMessage):
            let outGoing = currentSender().senderId == message.sender.senderId
            
            let name = self.getTitleText(isOutgoingMessage: outGoing, message: message, replyMessage: replyMessage)
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        default:
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
//            return nil
        }
        
    }
    
    func messageBottomLabelAttributedText(for message: MKMessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func messageActionLabelAttributedText(for action: MKActionType, at indexPath: IndexPath) -> NSAttributedString? {
        switch action {
        case .reply(let replyMessage):
//            let attributedText = NSAttributedString(string: replyMessage.content, attributes: [.font: UIFont.italicSystemFont(ofSize: 15)])
            let attributedText1 = NSMutableAttributedString(string: replyMessage.content, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.black])
            let attributedText2 = NSAttributedString(string: "\n12 giây", attributes: [.font: UIFont.italicSystemFont(ofSize: 13), .foregroundColor: UIColor.lightGray])
//            attributedText1.append(attributedText2)
            return attributedText1
        case .remove:
            let contentText = "Tin nhắn đã bị xoá"
            let attributedText: NSAttributedString = NSAttributedString(string: contentText, attributes: [.font: UIFont.italicSystemFont(ofSize: 13)])
            return attributedText
        default:
            return nil
        }
    }
    
    
}

// MARK: - MessageCellDelegate

extension ChatViewController: MKMessageCellDelegate {
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }

    func didTapBackground(in cell: MessageCollectionViewCell) {
        print("didTapBackgroundl tapped")
        self.view.endEditing(true)
        print(self.messagesCollectionView.frame)
        print(self.messagesCollectionView.contentOffset)
    }
    func cellDidLongPressMessage(cell: MessageCollectionViewCell) {
        print("long presss")
        
        contextMenu = ContextMenu()
        
       
        guard let contentCell = cell as? MessageContentCell else {return}
        let share = ContextMenuAction(title: "Trả lời", image: UIImage(named: "ic_audiocall_hangup"), tintColor: UIColor.black, action: {_ in
            print("Tra loi oke 13456")
        })
        let edit = "Edit"
        let delete = ContextMenuAction(title: "Delete", image: UIImage(named: "ic_audiocall_misscall"), tintColor: UIColor.brown, action: {_ in
            print("Delete 13456")
        })
        //        CM.nibView = UINib(nibName: "CustomCell", bundle: .main)
//        contextMenu?.items = ["Trả lời", "Sao chép", "Xoá"]
        contextMenu?.items = [share, delete]
        contentCell.messageBodyView.backgroundColor = .red
        contextMenu?.showMenu(viewTargeted: contentCell.messageBodyView, delegate: self)
        self.view.endEditing(true)
    }
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }

    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
    }

    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
    }

    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
    }

    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
    func didTapActionMessage(in cell: MessageCollectionViewCell) {
        print("MessageCollectionViewCell tapped")
    }

}

// MARK: - MessageLabelDelegate

extension ChatViewController: MKMessageLabelDelegate {
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }

    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }

    func didSelectMention(_ mention: String, target: String) {
        print("Mention selected: \(mention), target: \(target)")
    }

    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
        
    }
    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
//        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
//            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
//                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

    private func insertMessages(_ data: [Any]) {
        for component in data {
            let user = SampleData.shared.currentSender
            if let str = component as? String {
                let message = MockMessage(text: str, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            } else if let img = component as? UIImage {
                let message = MockMessage(image: img, user: user, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
}

extension ChatViewController: ContextMenuDelegate {
    func contextMenuDidSelect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuAction, forRowAt index: Int) -> Bool {
        print("contextMenuDidSelect: \(index)")
        return true
    }
    
    func contextMenuDidDeselect(_ contextMenu: ContextMenu, cell: ContextMenuCell, targetedView: UIView, didSelect item: ContextMenuAction, forRowAt index: Int) {
        print("contextMenuDidDeselect: \(index)")
    }
    
    func contextMenuDidAppear(_ contextMenu: ContextMenu) {
        print("contextMenuDidAppear")
    }
    
    func contextMenuDidDisappear(_ contextMenu: ContextMenu) {
        print("contextMenuDidDisappear")
        self.contextMenu = nil
    }

}

extension ChatViewController {

    func collectionViewDataSourceUI() -> (
            CollectionViewSectionedDataSource<ChatSection>.ConfigureCell
        ) {
        return (
             { _, cv, indexPath, i in
                guard let messagesCollectionView = cv as? MessagesCollectionView else {
                    fatalError("MessageKitError.notMessagesCollectionView")
                }

                guard let messagesDataSource = messagesCollectionView.messagesDataSource else {
                    fatalError("MessageKitError.nilMessagesDataSource")
                }

//                if isSectionReservedForTypingIndicator(indexPath.section) {
//                    return messagesDataSource.typingIndicator(at: indexPath, in: messagesCollectionView)
//                }

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
        )
    }

    // MARK: Initial value

    func initialValue() -> [ChatSection] {
        
        var listChatSection = [ChatSection]()
        for i in 0..<messageList.count {
            let section = ChatSection(header: "Section \(i + 1)", numbers: [messageList[i]], updated: messageList[i].sentDate)
            listChatSection.append(section)
        }
        return listChatSection
    }


}
class NumberSectionView : UICollectionReusableView {
    @IBOutlet private weak var value: UILabel?

    func configure(value: String) {
        self.value?.text = value
    }
}

final class RxCollectionViewSectionedReloadDataSourceWithReload<S: AnimatableSectionModelType>: RxCollectionViewSectionedAnimatedDataSource<S> {
    private let relay = PublishRelay<Void>()
    var dataReloaded : Signal<Void> {
        return relay.asSignal()
    }
    override func collectionView(_ collectionView: UICollectionView, observedEvent: Event<Element>) {
        super.collectionView(collectionView, observedEvent: observedEvent)
        print("Load xong ro day")
        relay.accept(())
    }
    
//    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
//        super.tableView(tableView, observedEvent: observedEvent)
//        relay.accept(())
//    }
}
final class RxTableViewSectionedReloadDataSourceWithReloadSignal11<S: SectionModelType>: RxTableViewSectionedReloadDataSource<S> {
    private let relay = PublishRelay<Void>()
    var dataReloaded : Signal<Void> {
        return relay.asSignal()
    }
    
    override func tableView(_ tableView: UITableView, observedEvent: Event<[S]>) {
        super.tableView(tableView, observedEvent: observedEvent)
        relay.accept(())
    }
}
