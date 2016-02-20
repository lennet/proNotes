//
//  TextLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 20/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class TextLayer: MovableLayer {
    private final let textKey = "text"
    var text: String

    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize, text: String) {
        self.text = text
        super.init(index: index, type: .Text, docPage: docPage, origin: origin, size: size)
    }

    required init(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObjectForKey(textKey) as! String
        super.init(coder: aDecoder)
    }

    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: textKey)
        super.encodeWithCoder(aCoder)
    }

    override func undoAction(oldObject: AnyObject?) {
        if let text = oldObject as? String {
            self.text = text
        } else {
            super.undoAction(oldObject)
        }
    }

    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? TextLayer else {
            return false
        }

        if !super.isEqual(object) {
            return false
        }

        return layer.text == self.text
    }

}