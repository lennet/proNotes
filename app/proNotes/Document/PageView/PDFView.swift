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

    init(pdfData: Data, frame: CGRect) {
        self.pdf = PDFUtility.createPDFFromData(data: pdfData as CFData)
        super.init(frame: frame)
        isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {
        if let page = pdf?.page(at: 1) {

            let context = UIGraphicsGetCurrentContext()

//            context?.ctm.
            context?.scale(x: 1, y: -1)
            context?.translate(x: 0, y: -rect.size.height)

            let mediaRect = page.getBoxRect(CGPDFBox.cropBox)

            context?.translate(x: -mediaRect.origin.x, y: -mediaRect.origin.y)

            context?.drawPDFPage(page);
        }
    }

}
