//
//  InputPositionControlling.swift
//  ChatExample
//
//  Created by Gapo on 11/9/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit

public protocol InputPositionControlling: AnyObject {

    var keyboardStatus: KeyboardStatus { get }

    var inputBarContainer: UIView! { get }
    var maximumInputSize: CGSize { get }

    var inputContentContainer: UIView! { get }
    var inputContentBottomMargin: CGFloat { get }

    func changeInputContentBottomMarginTo(_ newValue: CGFloat, animated: Bool, callback: (() -> Void)?)
    func changeInputContentBottomMarginTo(_ newValue: CGFloat, animated: Bool, duration: CFTimeInterval, initialSpringVelocity: CGFloat, callback: (() -> Void)?)
    func changeInputContentBottomMarginTo(_ newValue: CGFloat, animated: Bool, duration: CFTimeInterval, timingFunction: CAMediaTimingFunction, callback: (() -> Void)?)
}
