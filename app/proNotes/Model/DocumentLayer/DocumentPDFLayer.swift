//
//  DocumentPDFLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 20/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentPDFLayer: DocumentLayer {
    private final let pdfKey = "pdf"

    var pdfData: NSData?

    init(index: Int, pdfData: NSData, docPage: DocumentPage) {
        self.pdfData = pdfData
        super.init(index: index, type: .PDF, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        pdfData = aDecoder.decodeObjectForKey(pdfKey) as? NSData
        super.init(coder: aDecoder)
    }

    override func encodeWithCoder(aCoder: NSCoder) {

        if pdfData != nil {
            aCoder.encodeObject(pdfData, forKey: pdfKey)
        }

        super.encodeWithCoder(aCoder)
    }

    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? DocumentPDFLayer else {
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

