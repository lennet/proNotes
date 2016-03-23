//
//  MovableLayer.swift
//  proNotes
//
//  Created by Leo Thomas on 20/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class MovableLayer: DocumentLayer {
    private final let sizeKey = "size"
    private final let originKey = "origin"

    var origin: CGPoint
    var size: CGSize

    init(index: Int, type: DocumentLayerType, docPage: DocumentPage, origin: CGPoint, size: CGSize) {
        self.origin = origin
        self.size = size

        super.init(index: index, type: type, docPage: docPage)
    }

    required init(coder aDecoder: NSCoder) {
        origin = aDecoder.decodeCGPointForKey(originKey)
        size = aDecoder.decodeCGSizeForKey(sizeKey)
        super.init(coder: aDecoder)
    }

    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeCGPoint(origin, forKey: originKey)
        aCoder.encodeCGSize(size, forKey: sizeKey)
        super.encodeWithCoder(aCoder)
    }

    override func undoAction(oldObject: AnyObject?) {
        if let value = oldObject as? NSValue {
            let frame = value.CGRectValue()
            origin = frame.origin
            size = frame.size
        } else {
            super.undoAction(oldObject)
        }
    }

    override func isEqual(object: AnyObject?) -> Bool {
        guard let layer = object as? MovableLayer else {
            return false
        }

        if !super.isEqual(object) {
            return false
        }

        guard layer.origin == origin else {
            return false
        }

        guard layer.size == size else {
            return false
        }

        return true
    }

}