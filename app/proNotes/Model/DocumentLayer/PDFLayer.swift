//
//  PDFLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 20/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class PDFLayer: DocumentLayer {
    private final let pdfKey = "pdf"

    var pdfData: Data?

    init(index: Int, pdfData: Data, docPage: DocumentPage) {
        self.pdfData = pdfData
        super.init(index: index, type: .pdf, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        pdfData = aDecoder.decodeObject(forKey: pdfKey) as? Data
        super.init(coder: aDecoder)
    }

    override func encode(with aCoder: NSCoder) {

        if pdfData != nil {
            aCoder.encode(pdfData, forKey: pdfKey)
        }

        super.encode(with: aCoder)
    }

    override func isEqual(_ object: AnyObject?) -> Bool {
        guard let layer = object as? PDFLayer else {
            return false
        }

        if !super.isEqual(object) {
            return false
        }

        if layer.pdfData == nil && pdfData == nil {
            return true
        }

        if layer.pdfData != nil && pdfData != nil {
            return layer.pdfData == pdfData
        } else {
            return false
        }
    }
}

