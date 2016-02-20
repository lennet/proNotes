//
//  PDF.swift
//  proNotes
//
//  Created by Leo Thomas on 16/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class PDFUtility: NSObject {

    class func getPageAsPDF(pageIndex:Int, document: CGPDFDocument) -> CGPDFDocument? {
        if let data = getPageAsData(pageIndex, document: document) {
            return createPDFFromData(data)
        }
        return nil
    }
    
    class func createPDFFromData(data: CFData) -> CGPDFDocument? {
        let dataProvider = CGDataProviderCreateWithCFData(data)
        return CGPDFDocumentCreateWithProvider(dataProvider)
    }
    
    class func getPageAsData(pageIndex: Int, document: CGPDFDocument) -> CFData? {
        if let page = CGPDFDocumentGetPage(document, pageIndex) {
            var mediaBox = CGPDFPageGetBoxRect(page, .CropBox)
            let data = CFDataCreateMutable(kCFAllocatorDefault, 0)
            let consumer = CGDataConsumerCreateWithCFData(data)
            let context = CGPDFContextCreate(consumer, &mediaBox, nil)
            CGContextBeginPage(context, &mediaBox)
            CGContextDrawPDFPage(context, page)
            CGContextEndPage(context)
            CGPDFContextClose(context)
            return data
        }
        return nil
    }
    
    class func getPDFRect(document: CGPDFDocument, pageIndex: Int) -> CGRect{
        if let page = CGPDFDocumentGetPage(document, pageIndex) {
            return CGPDFPageGetBoxRect(page, .CropBox)
        }
        return CGRect.zero
    }
    
}
