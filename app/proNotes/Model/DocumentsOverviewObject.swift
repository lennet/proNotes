//
//  DocumentsOverviewObject.swift
//  proNotes
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentsOverviewObject: NSObject {

    var fileURL: URL
    var state: UIDocumentState?
    var version: NSFileVersion?
    var metaData: DocumentMetaData?
    var downloaded = false

    init(fileURL: URL, state: UIDocumentState?, metaData: DocumentMetaData?, version: NSFileVersion?) {
        self.fileURL = fileURL
        self.state = state
        self.version = version
        self.metaData = metaData
        super.init()
    }

    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init()
    }

    override var description: String {
        get {
            return fileURL.fileName(true) ?? super.description
        }
    }
}
