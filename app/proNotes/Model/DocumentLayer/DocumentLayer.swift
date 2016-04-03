//
//  DocumentLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 13/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

enum DocumentLayerType: Int {
    case PDF = 1
    case Sketch = 2
    case Image = 3
    case Text = 4
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

    init(fileWrapper: NSFileWrapper, index: Int, docPage: DocumentPage) {
        self.index = index
        self.type = .Sketch
        self.docPage = docPage
    }

    required init(coder aDecoder: NSCoder) {
        self.index = aDecoder.decodeIntegerForKey(indexKey)
        self.type = DocumentLayerType(rawValue: aDecoder.decodeIntegerForKey(typeRawValueKey))!
        self.hidden = aDecoder.decodeBoolForKey(hiddenKey)
        super.init()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(index, forKey: indexKey)
        aCoder.encodeInteger(type.rawValue, forKey: typeRawValueKey)
        aCoder.encodeBool(hidden, forKey: hiddenKey)
    }

    func removeFromPage() {
        self.docPage.removeLayer(self)
    }

    func undoAction(oldObject: AnyObject?) {
        // empty Base Implementation
    }

    override func isEqual(object: AnyObject?) -> Bool {
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


