//
//  PDFUtility.swift
//  proNotes
//
//  Created by Leo Thomas on 16/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import CoreGraphics

class PDFUtility {

    class func getPageAsPDF(_ pageIndex: Int, document: CGPDFDocument) -> CGPDFDocument? {
        
        guard let data = getPageAsData(pageIndex, document: document) else {
                return nil
        }
        
        return createPDFFromData(data: data)
        
    }

    class func createPDFFromData(data: CFData) -> CGPDFDocument? {
        let dataProvider = CGDataProvider(data: data)
        return CGPDFDocument(dataProvider!)
    }

    class func getPageAsData(_ pageIndex: Int, document: CGPDFDocument) -> CFData? {
       
        guard let page = document.page(at: pageIndex) else {
            return nil
        }
        
        var mediaBox = page.getBoxRect(.cropBox)
        guard let data = CFDataCreateMutable(kCFAllocatorDefault, 0), let consumer = CGDataConsumer(data: data) else {
            return nil
        }
        
        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return nil
        }
        
        context.beginPage(mediaBox: &mediaBox)
        context.drawPDFPage(page)
        context.endPage()
        context.closePDF()
        return data
    }

    class func getPDFRect(_ document: CGPDFDocument, pageIndex: Int) -> CGRect {
        guard let page = document.page(at: pageIndex) else {
            return .zero
        }
        
        return page.getBoxRect(.cropBox)
    }

}
