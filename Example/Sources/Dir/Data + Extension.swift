//
//  Data + Extension.swift
//  GAPO
//
//  Created by Gapo on 11/2/20.
//  Copyright © 2020 GAPO. All rights reserved.
//
import UIKit

extension Data {

    init?(path: String) {

        try? self.init(contentsOf: URL(fileURLWithPath: path))
    }

    func write(path: String, options: Data.WritingOptions = []) {

        try? self.write(to: URL(fileURLWithPath: path), options: options)
    }
}
