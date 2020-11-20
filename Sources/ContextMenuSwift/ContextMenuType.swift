//
//  ContextMenuType.swift
//  GAPO
//
//  Created by Gapo on 11/13/20.
//  Copyright © 2020 GAPO. All rights reserved.
//

import Foundation

enum ContextMenuType {
    
    case reply
    case copy
    case pin
    case forward
    case remove
    
    var name: String {
        switch self {
        case .reply:
            return "Trả lời"
        case .copy:
            return "Sao chép"
        case .pin:
            return "Ghim tin nhắn"
        case .forward:
            return "Chuyển tiếp"
        case .remove:
            return "Xoá tin nhắn"
        }
    }
        
    var icon: UIImage {
        switch self {
        case .reply:
            return UIImage(named: "chat-context-menu-reply")!
        case .copy:
            return UIImage(named: "chat-context-menu-copy")!
        case .pin:
            return UIImage(named: "chat-context-menu-pin")!
        case .forward:
            return UIImage(named: "chat-context-menu-forward")!
        case .remove:
            return UIImage(named: "chat-context-menu-remove")!
        }
    }
        
}
