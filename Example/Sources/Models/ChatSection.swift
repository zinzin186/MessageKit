//
//  ChatSection.swift
//  MessageKit
//
//  Created by Gapo on 02/12/2020.
//

import Foundation
import RxDataSources

struct ChatSection {
    var header: String

    var numbers: [MockMessage]

    var updated: Date

    init(header: String, numbers: [Item], updated: Date) {
        self.header = header
        self.numbers = numbers
        self.updated = updated
    }
}

// MARK: Just extensions to say how to determine identity and how to determine is entity updated

extension ChatSection
    : AnimatableSectionModelType {
    typealias Item = MockMessage
    typealias Identity = String

    var identity: String {
        return header
    }

    var items: [MockMessage] {
        return numbers
    }

    init(original: ChatSection, items: [Item]) {
        self = original
        self.numbers = items
    }
}

extension ChatSection
    : CustomDebugStringConvertible {
    var debugDescription: String {
        let interval = updated.timeIntervalSince1970
        let numbersDescription = numbers.map { "\n\($0.debugDescription)" }.joined(separator: "")
        return "NumberSection(header: \"\(self.header)\", numbers: \(numbersDescription)\n, updated: \(interval))"
    }
}

extension MockMessage
    : IdentifiableType
    , Equatable {
    typealias Identity = String

    var identity: String {
        return messageId
    }
}

// equatable, this is needed to detect changes
func == (lhs: MockMessage, rhs: MockMessage) -> Bool {
    return lhs.messageId == rhs.messageId
}

// MARK: Some nice extensions
extension MockMessage
    : CustomDebugStringConvertible {
    var debugDescription: String {
        return "IntItem(number: \(messageId), date: \(sentDate.timeIntervalSince1970))"
    }
}

extension MockMessage
    : CustomStringConvertible {

    var description: String {
        return "\(messageId)"
    }
}

extension ChatSection: Equatable {
    
}

func == (lhs: ChatSection, rhs: ChatSection) -> Bool {
    return lhs.header == rhs.header && lhs.items == rhs.items && lhs.updated == rhs.updated
}
