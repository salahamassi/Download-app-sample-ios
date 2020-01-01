//
//  URL+Extensions.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//

import UIKit
import PDFKit
import AVKit

extension URL {
    static func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        // Get document directory for device, this should succeed
        if let documentDirectory = fileManager.urls(for: .documentDirectory,
                                                    in: .userDomainMask).first {
            // Construct a URL with desired folder name
            let folderURL = documentDirectory.appendingPathComponent(folderName)
            // If folder URL does not exist, create it
            if !fileManager.fileExists(atPath: folderURL.path) {
                do {
                    // Attempt to create folder
                    try fileManager.createDirectory(atPath: folderURL.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    // Creation failed. Print error & return nil
                    print(error.localizedDescription)
                    return nil
                }
            }
            // Folder either exists, or was created. Return URL
            return folderURL
        }
        // Will only be called if document directory not found
        return nil
    }
    
    func createFolder(folderName: String) -> URL? {
        let fileManager = FileManager.default
        let folderURL = appendingPathComponent(folderName)
        // If folder URL does not exist, create it
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                // Attempt to create folder
                try fileManager.createDirectory(atPath: folderURL.path,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch {
                // Creation failed. Print error & return nil
                print(error.localizedDescription)
                return nil
            }
        }
        // Folder either exists, or was created. Return URL
        return folderURL
        
    }
    
    func sizeForLocalFilePath() -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(path)")
            }
            
        } catch {
            print("Failed to get file attributes for local path: \(path) with error: \(error)")
        }
        return 0
    }
    
    func sizeForDirectoryPath() -> UInt64 {
        let fullPath = (path as NSString).expandingTildeInPath
        
        do{
            let fileAttributes: NSDictionary = try FileManager.default.attributesOfItem(atPath: fullPath) as NSDictionary
            
            if fileAttributes.fileType() == "NSFileTypeRegular" {
                return fileAttributes.fileSize()
            }
            
            let url = NSURL(fileURLWithPath: fullPath)
            guard let directoryEnumerator = FileManager.default.enumerator(at: url as URL, includingPropertiesForKeys: [URLResourceKey.fileSizeKey], options: [.skipsHiddenFiles], errorHandler: nil) else { return 0 }
            
            var total: UInt64 = 0
            
            for (index, object) in directoryEnumerator.enumerated() {
                guard let fileURL = object as? NSURL else { return 0 }
                var fileSizeResource: AnyObject?
                try fileURL.getResourceValue(&fileSizeResource, forKey: URLResourceKey.fileSizeKey)
                guard let fileSize = fileSizeResource as? NSNumber else { continue }
                total += fileSize.uint64Value
                if index % 1000 == 0 {
                    print(".", terminator: "")
                }
            }
            return total
        }catch{
            print(error)
            return 0
        }
    }
    
    func remove(){
        do {
            try FileManager.default.removeItem(at: self)
        } catch {
            print(error)
        }
    }
    
    var pdfDoucment: PDFDocument?{
        get{
            return PDFDocument(url: self)
        }
    }
    
    var urlAsset: AVURLAsset?{
        get{
            return AVURLAsset(url: self, options: [:])
        }
    }
    func getThumb()-> UIImage?{
        if hasDirectoryPath { return #imageLiteral(resourceName: "baseline_folder_black_48pt").withRenderingMode(.alwaysTemplate)}
        // TODO imporve this if else shit
        if pathExtension.isImage{
            return nil
        }else if pathExtension.isVideo{
            return urlAsset?.captureThumbnails()
        }else if pathExtension.isAudio {
            return #imageLiteral(resourceName: "baseline_audiotrack_black_48pt").withRenderingMode(.alwaysTemplate)
        }else if pathExtension.isPdf {
            return pdfDoucment?.captureThumbnails(with: CGSize(width: 42, height: 42))
        }else if pathExtension.isDoc{
            return #imageLiteral(resourceName: "docs")
        }else if pathExtension.isXls{
            return #imageLiteral(resourceName: "xls")
        }else if pathExtension.isRtf{
            return #imageLiteral(resourceName: "rtf")
        }else if pathExtension.isCsv{
            return #imageLiteral(resourceName: "abdcc9688b")
        }else if pathExtension.isPpt{
            return #imageLiteral(resourceName: "ppt")
        }else if pathExtension.isText{
            return #imageLiteral(resourceName: "txt")
        }else  if pathExtension.isKotlin{
            return #imageLiteral(resourceName: "Kotlin")
        }else  if pathExtension.isSwift{
            return #imageLiteral(resourceName: "swift")
        }else  if pathExtension.isZip{
            return #imageLiteral(resourceName: "zip")
        }else{
            return #imageLiteral(resourceName: "document").withRenderingMode(.alwaysOriginal)
        }
    }
}
