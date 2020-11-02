//
//  MediaDownload.swift
//  GAPO
//
//  Created by Gapo on 11/2/20.
//  Copyright © 2020 GAPO. All rights reserved.
//

import UIKit

class MediaDownload: NSObject {

    class func user(_ name: String, pictureAt: Int, completion: @escaping (UIImage?, Error?) -> Void) {

        if (pictureAt != 0) {
            start(dir: "user", name: name, ext: "jpg", manual: false) { path, error in
                if (error == nil) {
                    completion(UIImage(contentsOfFile: path), nil)
                } else {
                    completion(nil, error)
                }
            }
        } else {
            completion(nil, NSError(domain: "Missing picture.", code: 100))
        }
    }

    // MARK: -
    class func photo(_ name: String, completion: @escaping (String, Error?) -> Void) {

        start(dir: "media", name: name, ext: "jpg", manual: true, completion: completion)
    }

    class func video(_ name: String, completion: @escaping (String, Error?) -> Void) {

        start(dir: "media", name: name, ext: "mp4", manual: true, completion: completion)
    }

    class func audio(_ name: String, completion: @escaping (String, Error?) -> Void) {

        start(dir: "media", name: name, ext: "m4a", manual: true, completion: completion)
    }

    class func sticker(_ urlString: String, completion: @escaping (String?) -> Void) {
        guard let link = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(nil)
            return
        }
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {return}
            Media.saveSticker(link, data: data)
            DispatchQueue.main.async(execute: {
                completion(link)
            })

        }.resume()

//        start(dir: "sticker", name: name, ext: "json", manual: true, completion: completion)
    }
    // MARK: -
    private class func start(dir: String, name: String, ext: String, manual: Bool, completion: @escaping (String, Error?) -> Void) {

        let file = "\(name).\(ext)"
        let path = Dir.document(dir, and: file)

        let fileManual = file + ".manual"
        let pathManual = Dir.document(dir, and: fileManual)

        let fileLoading = file + ".loading"
        let pathLoading = Dir.document(dir, and: fileLoading)

        // Check if file is already downloaded
        if File.exist(path: path) {
            completion(path, nil)
            return
        }

        // Check if manual download is required
        if manual {
            if File.exist(path: pathManual) {
                completion("", NSError(domain: "Manual download required.", code: 101))
                return
            }
            try? "manual".write(toFile: pathManual, atomically: false, encoding: .utf8)
        }

        // Check if file is currently downloading
        let time = Int(Date().timeIntervalSince1970)

        if File.exist(path: pathLoading) {
            if let temp = try? String(contentsOfFile: pathLoading, encoding: .utf8) {
                if let check = Int(temp) {
                    if time - check < 60 {
                        completion("", NSError(domain: "Already downloading.", code: 102))
                        return
                    }
                }
            }
        }
        try? "\(time)".write(toFile: pathLoading, atomically: false, encoding: .utf8)

        // Download the file
        FireStorage.download(dir: dir, name: name, ext: ext) { path, error in
            File.remove(path: pathLoading)
            DispatchQueue.main.async {
                completion(path, error)
            }
        }
    }
}
