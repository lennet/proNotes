//
//  PDFView.swift
//  Student
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol PDFViewDelegate: class {
    func updateHeight(height: CGFloat)
}

class PDFView: UIView, PageSubView {

    weak var delegate: PDFViewDelegate?

    var page: CGPDFPage?

    init(page: CGPDFPage, frame: CGRect) {
        self.page = page
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func drawRect(rect: CGRect) {
        if page != nil {

            let context = UIGraphicsGetCurrentContext()

            CGContextGetCTM(context)
            CGContextScaleCTM(context, 1, -1)
            CGContextTranslateCTM(context, 0, -rect.size.height)

            let mediaRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
            delegate?.updateHeight(mediaRect.height)

            let heightRatio = rect.size.height / mediaRect.size.height
            let widthRatio = rect.size.width / mediaRect.size.width

            var height: CGFloat = 0

            if heightRatio > widthRatio {
                height = mediaRect.height * heightRatio
                CGContextScaleCTM(context, heightRatio,
                        heightRatio)
            } else {
                height = mediaRect.height * widthRatio
                CGContextScaleCTM(context, widthRatio,
                        widthRatio)
            }

            CGContextTranslateCTM(context, -mediaRect.origin.x, -mediaRect.origin.y)

            delegate?.updateHeight(height)
            CGContextDrawPDFPage(context, page);
        }

    }

}
