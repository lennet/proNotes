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
        guard let page = pdf?.page(at: 1) else { return }

        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: 1, y: -1)
        context?.translateBy(x: 0, y: -rect.size.height)

        let mediaRect = page.getBoxRect(CGPDFBox.cropBox)

        context?.translateBy(x: -mediaRect.origin.x, y: -mediaRect.origin.y)

        context?.drawPDFPage(page);
    }

}
