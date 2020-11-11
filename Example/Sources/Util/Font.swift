//
//  Font.swift
//  ChatExample
//
//  Created by Gapo on 11/11/20.
//  Copyright © 2020 MessageKit. All rights reserved.
//

import UIKit
let widthRatio: CGFloat = min(UIScreen.main.bounds.width/375.0, 1.0)
let heightRatio: CGFloat = min(UIScreen.main.bounds.height/667.0, 1.0)

typealias MainFont = Font.HelveticaNeue

enum Font {
    enum HelveticaNeue: String {
        case ultraLightItalic = "UltraLightItalic"
        case medium = "Medium"
        case mediumItalic = "MediumItalic"
        case ultraLight = "UltraLight"
        case italic = "Italic"
        case light = "Light"
        case thinItalic = "ThinItalic"
        case lightItalic = "LightItalic"
        case bold = "Bold"
        case thin = "Thin"
        case condensedBlack = "CondensedBlack"
        case condensedBold = "CondensedBold"
        case boldItalic = "BoldItalic"

        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "HelveticaNeue-\(rawValue)", size: size)
                ?? UIFont.systemFont(ofSize: size)
        }
    }

    enum SFProText: String {
        case regular = "Regular"
        case bold = "Bold"
        case medium = "Medium"
        case semibold = "Semibold"

        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "SFProText-\(rawValue)", size: size)
                ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    enum SFProDisplay: String {
        case regular = "Regular"
        case bold = "Bold"
        case medium = "Medium"
        case semibold = "Semibold"
        
        func with(size: CGFloat) -> UIFont {
            return UIFont(name: "SFProDisplay-\(rawValue)", size: size)
                ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    static func adaptSize(_ size: CGFloat) -> CGFloat {
        let newSize = ceil(size * widthRatio)
        return newSize
    }
}
