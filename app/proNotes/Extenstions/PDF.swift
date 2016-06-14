//
//  PDF.swift
//  proNotes
//
//  Created by Leo Thomas on 16/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class PDFUtility: NSObject {

    class func getPageAsPDF(_ pageIndex: Int, document: CGPDFDocument) -> CGPDFDocument? {
        if let data = getPageAsData(pageIndex, document: document) {
            return createPDFFromData(data)
        }
        return nil
    }

    class func createPDFFromData(_ data: CFData) -> CGPDFDocument? {
        let dataProvider = CGDataProvider(data: data)
        return CGPDFDocument(dataProvider!)
    }

    class func getPageAsData(_ pageIndex: Int, document: CGPDFDocument) -> CFData? {
        if let page = document.page(at: pageIndex) {
            var mediaBox = page.getBoxRect(.cropBox)
            let data = CFDataCreateMutable(kCFAllocatorDefault, 0)
            let consumer = CGDataConsumer(data: data!)
            let context = CGContext(consumer: consumer!, mediaBox: &mediaBox, nil)
            context?.beginPage(mediaBox: &mediaBox)
            context?.drawPDFPage(page)
//            context?.endPage()
            context?.closePDF()
            return data
        }
        return nil
    }

    class func getPDFRect(_ document: CGPDFDocument, pageIndex: Int) -> CGRect {
        if let page = document.page(at: pageIndex) {
            return page.getBoxRect(.cropBox)
        }
        return CGRect.zero
    }

}
