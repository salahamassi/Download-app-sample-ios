//
//  PDFDocument+Extensions.swift
//  Download App
//
//  Created by Salah Amassi on 1/1/20.
//  Copyright © 2020 Salah Amassi. All rights reserved.
//

import PDFKit

extension PDFDocument{
    func captureThumbnails(with size: CGSize = CGSize(width: 82, height: 82)) -> UIImage? {
        if let page1 = page(at: 1) {
            return page1.thumbnail(of: size, for: .artBox)
        }
        
        if let page2 = page(at: 2) {
            return page2.thumbnail(of: size, for: .artBox)
        }
        
        return nil
    }
}

