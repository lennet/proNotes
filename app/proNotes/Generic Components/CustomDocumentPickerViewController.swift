//
//  CustomDocumentPickerViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 19/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class CustomDocumentPickerViewController: UIDocumentPickerViewController {

    var documentTypes = [String]()

    override init(documentTypes allowedUTIs: [String], inMode mode: UIDocumentPickerMode) {
        self.documentTypes = allowedUTIs
        super.init(documentTypes: allowedUTIs, inMode: mode)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
