//
//  FireStorage.swift
//  GAPO
//
//  Created by Gapo on 11/2/20.
//  Copyright © 2020 GAPO. All rights reserved.
//

import UIKit

class FireStorage: NSObject {
    //Check func upoad

    class func download(dir: String, name: String, ext: String, completion: @escaping (_ path: String, _ error: Error?) -> Void) {

        let storage = "\(dir)/\(name).\(ext)"
        let file = "\(name).\(ext)"
        let path = Dir.document(dir, and: file)
        completion(path, nil)
    }
}
