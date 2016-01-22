//
//  DocumentsOverviewObject.swift
//  Student
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentsOverviewObject: NSObject {

    var fileURL: NSURL
    var state: UIDocumentState?
    var version: NSFileVersion?
    var metaData: DocumentMetaData?
    var downloaded = false
    
    init(fileURL: NSURL, state: UIDocumentState, metaData: DocumentMetaData?, version: NSFileVersion?){
        self.fileURL = fileURL
        self.state = state
        self.version = version
        self.metaData = metaData
        super.init()
    }
    
    init(fileURL: NSURL) {
        self.fileURL = fileURL
        super.init()
    }

    override var description: String {
        get {
            return fileURL.fileName() ?? super.description
        }
    }
}
