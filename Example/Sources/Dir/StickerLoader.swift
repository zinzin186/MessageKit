//
//  StickerLoader.swift
//  GAPO
//
//  Created by Gapo on 11/2/20.
//  Copyright © 2020 GAPO. All rights reserved.
//
import MessageKit

class StickerLoader: NSObject {

    class func getPathAnimation(url: String, completion: @escaping(String?) -> Void) {
        if let path = StickerLoader.pathSticker(url) {
           completion(path)
        } else {
            downloadStickerMedia(url: url) { (path) in
                completion(path)
            }
        }
    }

    class func pathSticker(_ name: String) -> String? { return path(dir: "sticker", name: name) }
    
    private class func path(dir: String, name: String) -> String? {
        if let escapedString = name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            let path = Dir.document(dir, and: escapedString)
            return Dir.exist(path: path) ? path : nil
        }
        return nil
        
    }
    private class func downloadStickerMedia(url: String, completion: @escaping(String?) -> Void) {
        self.sticker(url) {path in
            completion(path)
        }
    }
    class func sticker(_ urlString: String, completion: @escaping (String?) -> Void) {
        guard let link = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            completion(nil)
            return
        }
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = data else {return}
            StickerLoader.saveSticker(link, data: data)
            DispatchQueue.main.async(execute: {
                completion(link)
            })
        }.resume()

    }
    
    class func saveSticker(_ name: String, data: Data) {
        save(data: data, dir: "sticker", fileName: name)
    }
    
    private class func save(data: Data, dir: String, fileName: String) {
        let path = Dir.document(dir, and: fileName)
        data.write(path: path, options: .atomic)
    }
}
