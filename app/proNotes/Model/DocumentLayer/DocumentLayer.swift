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
    private final let hiddenKey = "key"
    private final let nameKey = "name"

    var index: Int
    var type: DocumentLayerType
    var name: String
    weak var docPage: DocumentPage!
    var hidden = false

    init(index: Int, type: DocumentLayerType, docPage: DocumentPage) {
        self.index = index
        self.type = type
        self.docPage = docPage
        self.name = String(type)
    }

    init(fileWrapper: FileWrapper, index: Int, docPage: DocumentPage) {
        self.index = index
        self.type = .sketch
        self.docPage = docPage
        self.name = String(type)
    }
    
    required init(coder aDecor: NSCoder) {
        fatalError("init(coder:type:) has not been implemented")
    }

    required init(coder aDecoder: NSCoder, type: DocumentLayerType) {
        self.index = aDecoder.decodeInteger(forKey: indexKey)
        self.name = (aDecoder.decodeObject(forKey: nameKey) as? String) ?? String(type)
        self.hidden = aDecoder.decodeBool(forKey: hiddenKey)
        self.type = type
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(index, forKey: indexKey)
        aCoder.encode(hidden, forKey: hiddenKey)
        aCoder.encode(name, forKey: nameKey)
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
        
        guard layer.name == name else {
            return false
        }

        return layer.hidden == hidden
    }
}


