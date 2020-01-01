//
//  DownloadManger.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//

import UIKit
import Alamofire

class DownloadManger: NSObject {
    
    private var sampleEndedCount: Int?
    private let queue = OperationQueue()
    
    class var shared: DownloadManger{
        struct Static{
            static let instance = DownloadManger()
        }
        return Static.instance
    }
    
    private lazy var backgroundManager: Alamofire.SessionManager = {
        let bundleIdentifier = "salah.File-Manger-App"
        return Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: bundleIdentifier + ".background"))
    }()
    
    var backgroundCompletionHandler: (() -> Void)? {
        get {
            return backgroundManager.backgroundCompletionHandler
        }
        set {
            backgroundManager.backgroundCompletionHandler = newValue
        }
    }
    
    func setupDownloadQueue(){
        queue.maxConcurrentOperationCount = 2
    }
    
    
    func download(file: String?, pathExtension: String? = nil, fileName: String? = nil, thumb: String? = nil){
        guard let file = file else { return }
        guard let url = URL(string: file) else { return }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let download = Download(context: context)
        
        download.duration = 0.0
        download.title = fileName ?? UUID.init().uuidString
        download.url = url
        download.thumb = thumb
        if let pathExtension = pathExtension{
            if pathExtension.isVideo{
                download.type = Constants.DownloadType.video
            }else if pathExtension.isAudio{
                download.type = Constants.DownloadType.audio
            }else if pathExtension.isImage{
                download.thumb = url.absoluteString
                download.type = Constants.DownloadType.image
            }else if pathExtension.isDocumnet{
                download.type = Constants.DownloadType.document
            }else if pathExtension.isZip{
                download.type = Constants.DownloadType.zip
                
            }
        }else{
            download.thumb = url.absoluteString
            download.type = Constants.DownloadType.image
        }
        download.createdAt = Date()
        appDelegate.saveContext()
        
        let operation = BlockOperation(block: {
            DispatchQueue.main.async {
                self.download(download: download, pathExtension: pathExtension)
            }
        })
        
        queue.addOperation(operation)
        
        if queue.operationCount > 1{
            operation.addDependency(queue.operations[queue.operationCount - 2])
        }
    }
    
    
    func download(download: Download, pathExtension: String? = nil){
        guard let url = download.url else { return }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, _ in
            _ = URL.createFolder(folderName: Constants.FoldersNames.DOWNLOADS)!
            let fileName: String
            if let pathExtension = pathExtension {
                fileName = Constants.FoldersNames.DOWNLOADS + "/" + (download.title ?? UUID.init().uuidString)  + "." + pathExtension
            }else{
                fileName =  Constants.FoldersNames.DOWNLOADS + "/" + (download.title ?? UUID.init().uuidString)  + "." + temporaryURL.pathExtension
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                download.localFile = fileName
                appDelegate.saveContext()
                if download.type == Constants.DownloadType.video || download.type == Constants.DownloadType.audio{
                     self.genrateThumbnailImageForMedia(download: download)
                }else if download.type == Constants.DownloadType.document{
                    self.genrateThumbnailImageForPdf(download: download)
                }
            }
            return (fileName.localURL!, [.removePreviousFile])
        }
        
        backgroundManager.download(url, to: destination).downloadProgress { (progress) in
            download.progress = progress.fractionCompleted
            print("progress", download.progress)
            appDelegate.saveContext()
        }.response {(response) in
            if let error = response.error{
                print("error", error)
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                context.delete(download)
                appDelegate.saveContext()
            }
        }
    }
    
    private func genrateThumbnailImageForMedia(download: Download){
        guard let localFileURL = download.localFile?.localURL else { return }
        guard let thumbnail = localFileURL.urlAsset?.captureThumbnails() else { return }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        _ = URL.createFolder(folderName: Constants.FoldersNames.THUMBNAILS)!
        let fileName = Constants.FoldersNames.THUMBNAILS + "/" + UUID.init().uuidString  + ".png"
        guard let imageData = thumbnail.pngData() else { return }
        guard let url = fileName.localURL else { return }
        do {
            try imageData.write(to: url)
            download.thumb = fileName
            appDelegate.saveContext()
        }catch {
            print("Error inserting image : \(error)")
        }
    }
    
    private func genrateThumbnailImageForPdf(download: Download){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        guard let pdfDoucment = download.localFile?.localURL?.pdfDoucment else { return }
        _ = URL.createFolder(folderName: Constants.FoldersNames.THUMBNAILS)!
        let fileName = Constants.FoldersNames.THUMBNAILS + "/" + UUID.init().uuidString  + ".png"
        guard let imageData = pdfDoucment.captureThumbnails()?.pngData() else { return }
        guard let url = fileName.localURL else { return }
        do {
            try  imageData.write(to: url)
            download.thumb = fileName
            appDelegate.saveContext()
        }catch {
            print("Error inserting image : \(error)")
        }
    }
}



