//
//  Document.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class Document: NSObject {
    var name = ""
    var numberOfPages = 1
    var pdf: CGPDFDocumentRef?
    
    
    func addPDF(url: NSURL){
        pdf = CGPDFDocumentCreateWithURL(url as CFURLRef)
        numberOfPages += CGPDFDocumentGetNumberOfPages(pdf)
    }
}
