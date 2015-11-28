//
//  PDFView.swift
//  Student
//
//  Created by Leo Thomas on 26/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol PDFViewDelegate {
    func updateHeight(height: CGFloat)
}

class PDFView: UIView {
    
    var delegate: PDFViewDelegate?
    
    var page: CGPDFPage?

    override func drawRect(rect: CGRect) {
        
        if page != nil {
            
            let context = UIGraphicsGetCurrentContext()
        
            CGContextGetCTM(context)
            CGContextScaleCTM(context, 1, -1)
            CGContextTranslateCTM(context, 0, -rect.size.height)
            
            let mediaRect = CGPDFPageGetBoxRect(page, CGPDFBox.CropBox)
            delegate?.updateHeight(mediaRect.height)
            
            let height = rect.size.height / mediaRect.size.height
            let width = rect.size.width / mediaRect.size.width
            CGContextScaleCTM(context, width,
                height)
            CGContextTranslateCTM(context, -mediaRect.origin.x, -mediaRect.origin.y)

            delegate?.updateHeight(mediaRect.height)
            CGContextDrawPDFPage(context, page);

        }
       
    }

}
