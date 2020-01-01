//
//  AVURLAsset+Extensions.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//

import AVFoundation
import UIKit


extension AVURLAsset{
    
    var durationInSeconds: Double{
        get{
            return CMTimeGetSeconds(duration)
        }
    }

    func captureThumbnails()-> UIImage?{
        let assetImgGenerate = AVAssetImageGenerator(asset: self)
        let videoDuration:CMTime = duration
        let denominator = videoDuration.timescale
        var actualTime = CMTime.zero
        let time = CMTimeMakeWithSeconds(durationInSeconds / 2, preferredTimescale: denominator)
        let img = try? assetImgGenerate.copyCGImage(at: time, actualTime: &actualTime)
        if img == nil{
            return nil
        }
        return UIImage(cgImage: img!)
    }
}
