//
//  MKPhotoLoader.swift
//  GAPO
//
//  Created by Gapo on 11/2/20.
//  Copyright © 2020 GAPO. All rights reserved.
//

import MessageKit

class MKPhotoLoader: NSObject {

    class func start(_ mkmessage: MKMessageType, in messagesCollectionView: MessagesCollectionView) {

        if let path = Media.pathPhoto(mkmessage.messageId) {
            showMedia(mkmessage, path: path)
        } else {
            loadMedia(mkmessage, in: messagesCollectionView)
        }
    }

    class func manual(_ mkmessage: MKMessageType, in messagesCollectionView: MessagesCollectionView) {

        Media.clearManualPhoto(mkmessage.messageId)
        downloadMedia(mkmessage, in: messagesCollectionView)
        messagesCollectionView.reloadData()
    }

    private class func loadMedia(_ mkmessage: MKMessageType, in messagesCollectionView: MessagesCollectionView) {

//        let network = Persons.networkPhoto()
//
//        if (network == Network.Manual) || ((network == Network.WiFi) && (Connectivity.isReachableViaWiFi() == false)) {
//            mkmessage.mediaStatus = MediaStatus.Manual
//        } else {
//            downloadMedia(mkmessage, in: messagesCollectionView)
//        }
        downloadMedia(mkmessage, in: messagesCollectionView)
    }

    private class func downloadMedia(_ mkmessage: MKMessageType, in messagesCollectionView: MessagesCollectionView) {

//        mkmessage.mediaStatus = MediaStatus.Loading

        MediaDownload.photo(mkmessage.messageId) { path, error in
            if (error == nil) {
                showMedia(mkmessage, path: path)
            } else {
//                mkmessage.mediaStatus = MediaStatus.Manual
            }
            messagesCollectionView.reloadData()
        }
    }

    private class func showMedia(_ mkmessage: MKMessageType, path: String) {

//        mkmessage.photoItem?.image = UIImage(path: path)
//        mkmessage.mediaStatus = MediaStatus.Succeed
    }
}
