//
//  File.swift
//  GAPO
//
//  Created by Gapo on 11/2/20.
//  Copyright © 2020 GAPO. All rights reserved.
//

import Foundation
import UIKit

class File: NSObject {

//    class func temp(ext: String) -> String {
//
//        let timestamp = Date().timestamp()
//        let file = "\(timestamp).\(ext)"
//        return Dir.cache(file)
//    }

    class func exist(path: String) -> Bool {

        return FileManager.default.fileExists(atPath: path)
    }

    class func remove(path: String) {

        try? FileManager.default.removeItem(at: URL(fileURLWithPath: path))
    }

    class func copy(src: String, dest: String, overwrite: Bool) {

        if (overwrite) { remove(path: dest) }

        if (exist(path: dest) == false) {
            try? FileManager.default.copyItem(atPath: src, toPath: dest)
        }
    }

    class func created(path: String) -> Date {

//        let attributes = try! FileManager.default.attributesOfItem(atPath: path)
//        return attributes[.creationDate] as! Date
        return Date()
    }

    class func modified(path: String) -> Date {

//        let attributes = try! FileManager.default.attributesOfItem(atPath: path)
//        return attributes[.modificationDate] as! Date
        return Date()
    }

    class func size(path: String) -> Int64 {
//
//        let attributes = try! FileManager.default.attributesOfItem(atPath: path)
//        return attributes[.size] as! Int64
        return 0
    }

    class func diskFree() -> Int64 {

//        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        let attributes = try! FileManager.default.attributesOfFileSystem(forPath: path)
//        return attributes[.systemFreeSize] as! Int64
        return 0
    }
}

