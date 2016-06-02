//
//  PDFView.swift
//  proNotes
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PDFView: UIView, PageSubView {

    var pdf: CGPDFDocument?

    init(pdfData: NSData, frame: CGRect) {
        self.pdf = PDFUtility.createPDFFromData(pdfData as CFData)
        super.init(frame: frame)
        userInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {
        if let page = CGPDFDocumentGetPage(pdf, 1) {

            let context = UIGraphicsGetCurrentContext()

            CGContextGetCTM(context)
            CGContextScaleCTM(context, 1, -1)
            CGContextTranslateCTM(context, 0, -rect.size.height)

            let mediaRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)

            CGContextTranslateCTM(context, -mediaRect.origin.x, -mediaRect.origin.y)

            CGContextDrawPDFPage(context, page);
        }
    }

}
