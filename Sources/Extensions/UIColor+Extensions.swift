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

import Foundation
import UIKit

internal extension UIColor {

    private static func colorFromAssetBundle(named: String) -> UIColor {
        if #available(iOS 11.0, *) {
            guard let color = UIColor(named: named, in: Bundle.messageKitAssetBundle, compatibleWith: nil) else {
                fatalError(MessageKitError.couldNotFindColorAsset)
            }
            return color
        } else {
            return UIColor.white
        }
        
    }
    
    static var incomingMessageBackground: UIColor { colorFromAssetBundle(named: "incomingMessageBackground")  }

    static var outgoingMessageBackground: UIColor { colorFromAssetBundle(named: "outgoingMessageBackground") }
    
    static var incomingMessageLabel: UIColor { colorFromAssetBundle(named: "incomingMessageLabel") }
    
    static var outgoingMessageLabel: UIColor { colorFromAssetBundle(named: "outgoingMessageLabel") }
    
    static var incomingAudioMessageTint: UIColor { colorFromAssetBundle(named: "incomingAudioMessageTint") }
    
    static var outgoingAudioMessageTint: UIColor { colorFromAssetBundle(named: "outgoingAudioMessageTint") }

    static var collectionViewBackground: UIColor { colorFromAssetBundle(named: "collectionViewBackground") }

    static var typingIndicatorDot: UIColor { colorFromAssetBundle(named: "typingIndicatorDot") }
    
    static var label: UIColor { colorFromAssetBundle(named: "label") }
    
    static var avatarViewBackground: UIColor { colorFromAssetBundle(named: "avatarViewBackground") }

}

internal extension UIColor {
    
    convenience init(hex: Int) {
        self.init(hex: hex, a: 1.0)
    }
    
    convenience init(hex: Int, a: CGFloat) {
        self.init(r: (hex >> 16) & 0xff, g: (hex >> 8) & 0xff, b: hex & 0xff, a: a)
    }
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(r: r, g: g, b: b, a: 1.0)
    }
    
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
    
    convenience init?(hexString: String) {
        var hexString = hexString.replacingOccurrences(of: "#", with: "")
        if hexString.count == 3 {
            hexString += hexString
        }
        guard let hex = Int(hexString, radix: 16) else { return nil }
        self.init(hex: hex)
    }
    
    static func fromHexCode(_ hexString: String) -> UIColor {
        return UIColor(hexString: hexString) ?? .clear
    }
}
