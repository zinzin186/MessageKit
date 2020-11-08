//
//  BaseChatViewControllerView.swift
//  ChatExample
//
//  Created by Gapo on 11/9/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit

// If you wish to use your custom view instead of BaseChatViewControllerView, you must implement this protocol.
public protocol BaseChatViewControllerViewProtocol: class {
    var bmaInputAccessoryView: UIView? { get set }
}

// http://stackoverflow.com/questions/24596031/uiviewcontroller-with-inputaccessoryview-is-not-deallocated
final class BaseChatViewControllerView: UIView, BaseChatViewControllerViewProtocol {

    var bmaInputAccessoryView: UIView?

    override var inputAccessoryView: UIView? {
        get {
            return self.bmaInputAccessoryView
        }
        set {
            self.bmaInputAccessoryView = newValue
        }
    }
}
