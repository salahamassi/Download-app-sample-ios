//
//  Extensions+String.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//

import Foundation

extension String{
   var url: URL? {
        get{
            return URL(string: self)
        }
    }
    
    var localURL: URL? {
        get{
            guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil}
            return documentsURL.appendingPathComponent(self)
        }
    }
    
    var encodingText: String{
        get{
            return (addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? self)
        }
    }
    
    var isImage: Bool{
        get{
            return caseInsensitiveCompare("png") == .orderedSame || caseInsensitiveCompare("jpg") == .orderedSame || caseInsensitiveCompare("jpeg") == .orderedSame ||
                caseInsensitiveCompare("heic") == .orderedSame ||
                caseInsensitiveCompare("tmp") == .orderedSame
        }
    }
    
    var isVideo: Bool{
        get{
            return caseInsensitiveCompare("mp4") == .orderedSame || caseInsensitiveCompare("flv") == .orderedSame || caseInsensitiveCompare("mov") == .orderedSame
        }
    }
    
    var isAudio: Bool{
        get{
            return caseInsensitiveCompare("m4a") == .orderedSame || caseInsensitiveCompare("mp3") == .orderedSame || caseInsensitiveCompare("wav") == .orderedSame || caseInsensitiveCompare("wma") == .orderedSame  || caseInsensitiveCompare("ogg") == .orderedSame  || caseInsensitiveCompare("raw") == .orderedSame
        }
    }
    
    var isVideoOrAudio: Bool{
        get{
            return isVideo || isAudio
        }
    }
    
    var isMedia: Bool{
        get{
            return isVideoOrAudio || isImage
        }
    }
    
    var isDocumnet: Bool{
        get{
            return caseInsensitiveCompare("pdf") == .orderedSame || caseInsensitiveCompare("doc") == .orderedSame ||  caseInsensitiveCompare("docx") == .orderedSame || caseInsensitiveCompare("RTF") == .orderedSame || caseInsensitiveCompare("UTI") == .orderedSame || caseInsensitiveCompare("csv") == .orderedSame ||
                caseInsensitiveCompare("ppt") == .orderedSame || caseInsensitiveCompare("xls") == .orderedSame || caseInsensitiveCompare("txt") == .orderedSame || caseInsensitiveCompare("text") == .orderedSame || caseInsensitiveCompare("pages") == .orderedSame || caseInsensitiveCompare("swift") == .orderedSame
                || caseInsensitiveCompare("java") == .orderedSame || caseInsensitiveCompare("html") == .orderedSame
                || caseInsensitiveCompare("xml") == .orderedSame  || caseInsensitiveCompare("c") == .orderedSame
                || caseInsensitiveCompare("m") == .orderedSame || caseInsensitiveCompare("cp") == .orderedSame
                || caseInsensitiveCompare("cpp") == .orderedSame || caseInsensitiveCompare("cc") == .orderedSame
                || caseInsensitiveCompare("cxx") == .orderedSame || caseInsensitiveCompare("c++") == .orderedSame
                || caseInsensitiveCompare("h") == .orderedSame || caseInsensitiveCompare("hpp") == .orderedSame
                || caseInsensitiveCompare("h++") == .orderedSame || caseInsensitiveCompare("hxx") == .orderedSame
                || caseInsensitiveCompare("kt") == .orderedSame || caseInsensitiveCompare("s") == .orderedSame
                || caseInsensitiveCompare("r") == .orderedSame || caseInsensitiveCompare("py") == .orderedSame
                || caseInsensitiveCompare("rb") == .orderedSame || caseInsensitiveCompare("php") == .orderedSame
                || caseInsensitiveCompare("applescript") == .orderedSame || caseInsensitiveCompare("js") == .orderedSame
                || caseInsensitiveCompare("css") == .orderedSame || caseInsensitiveCompare("js") == .orderedSame
        }
    }
    
    
    var isPdf: Bool{
        get{
            return caseInsensitiveCompare("pdf") == .orderedSame
        }
    }
    
    var isDoc: Bool{
        get{
            return caseInsensitiveCompare("doc") == .orderedSame || caseInsensitiveCompare("docx") == .orderedSame || caseInsensitiveCompare("pages") == .orderedSame
        }
    }
    
    var isXls: Bool{
        get{
            return caseInsensitiveCompare("xls") == .orderedSame
        }
    }
    
    
    var isRtf: Bool{
        get{
            return caseInsensitiveCompare("RTF") == .orderedSame
        }
    }
    
    var isCsv: Bool{
        get{
            return caseInsensitiveCompare("csv") == .orderedSame
        }
    }
    
    var isPpt: Bool{
        get{
            return caseInsensitiveCompare("ppt") == .orderedSame
        }
    }
    
    var isText: Bool{
        get{
            return caseInsensitiveCompare("txt") == .orderedSame || caseInsensitiveCompare("text") == .orderedSame || caseInsensitiveCompare("uti") == .orderedSame
        }
    }
    
    var isKotlin: Bool{
        get{
            return caseInsensitiveCompare("kt") == .orderedSame
        }
    }
    
    var isSwift: Bool{
        get{
            return caseInsensitiveCompare("swift") == .orderedSame
        }
    }
    
    var isZip: Bool{
        get{
            return caseInsensitiveCompare("zip") == .orderedSame
        }
    }
    
    var noIcon: Bool{
        if isSwift || isKotlin || isPdf || isPpt || isText || isCsv || isRtf || isXls || isDoc
            || isPdf || isImage || isVideoOrAudio || isZip{
            return false
        }else{
            return true
        }
    }
}
