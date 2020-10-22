//
//  CallMessageSizeCalculator.swift
//  MessageKit
//
//  Created by Gapo on 10/22/20.
//

import Foundation
import UIKit

open class CallMessageSizeCalculator: MessageSizeCalculator {

    open override func messageContainerSize(for message: MKMessageType, indexPath: IndexPath) -> CGSize {
        return MKMessageConstant.Sizes.Call.callView
    }
}

