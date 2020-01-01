//
//  Constants.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//

import Foundation

class Constants{
    class CoreData{
        static let containerName = "Download"
        static let downloadEntityName = "Download"
    }
    
    class FoldersNames{
        static let DOWNLOADS = "downloads"
        static let THUMBNAILS = "thumbnails"
    }
    
    class DownloadType{
        static let video = "video"
        static let audio = "audio"
        static let image = "image"
        static let document = "document"
        static let zip = "zip"
    }
    
    class ReuseIdentifier{
        static let download = "downloadCellId"
    }
}
