//
//  DocumentLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

enum DocumentLayerType: Int {
    case pdf = 1
    case sketch = 2
    case image = 3
    case text = 4
}

class DocumentLayer: NSObject, NSCoding {
    private final let indexKey = "index"
    private final let typeRawValueKey = "type"
    private final let hiddenKey = "key"

    var index: Int
    var type: DocumentLayerType
    weak var docPage: DocumentPage!
    var hidden = false

    init(index: Int, type: DocumentLayerType, docPage: DocumentPage) {
        self.index = index
        self.type = type
        self.docPage = docPage
    }

    init(fileWrapper: FileWrapper, index: Int, docPage: DocumentPage) {
        self.index = index
        self.type = .sketch
        self.docPage = docPage
    }

    required init(coder aDecoder: NSCoder) {
        self.index = aDecoder.decodeInteger(forKey: indexKey)
        self.type = DocumentLayerType(rawValue: aDecoder.decodeInteger(forKey: typeRawValueKey))!
        self.hidden = aDecoder.decodeBool(forKey: hiddenKey)
        super.init()
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(index, forKey: indexKey)
        aCoder.encode(type.rawValue, forKey: typeRawValueKey)
        aCoder.encode(hidden, forKey: hiddenKey)
    }

    func removeFromPage() {
        self.docPage.removeLayer(self)
    }

    func undoAction(_ oldObject: AnyObject?) {
        // empty Base Implementation
    }

    override func isEqual(_ object: AnyObject?) -> Bool {
        guard let layer = object as? DocumentLayer else {
            return false
        }

        guard layer.type == type else {
            return false
        }

        guard layer.index == index else {
            return false
        }

        return layer.hidden == hidden
    }
}


