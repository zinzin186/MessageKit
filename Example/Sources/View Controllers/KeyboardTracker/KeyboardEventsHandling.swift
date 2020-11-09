//
//  KeyboardEventsHandling.swift
//  ChatExample
//
//  Created by Gapo on 11/7/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit

public protocol KeyboardEventsHandling: AnyObject {
    func onKeyboardStateDidChange(_ height: CGFloat, _ status: KeyboardStatus)
}

public protocol ScrollViewEventsHandling: AnyObject {
    func onScrollViewDidScroll(_ scrollView: UIScrollView)
    func onScrollViewDidEndDragging(_ scrollView: UIScrollView, _ decelerate: Bool)
}
