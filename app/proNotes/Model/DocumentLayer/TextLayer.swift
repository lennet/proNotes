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
    private final let textColorKey = "textColor"
    private final let backgroundColorKey = "backgroundColor"
    private final let fontKey = "font"
    private final let alignmentKey = "alignment"
    
    var text: String
    var backgroundColor: UIColor
    var textColor: UIColor
    var font: UIFont
    var alignment: NSTextAlignment

    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize, text: String) {
        self.text = text
        self.backgroundColor = UIColor.clearColor()
        self.textColor = UIColor.blackColor()
        self.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        self.alignment = .Left
        super.init(index: index, type: .Text, docPage: docPage, origin: origin, size: size)
    }

    required init(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObjectForKey(textKey) as! String
        backgroundColor = aDecoder.decodeObjectForKey(backgroundColorKey) as! UIColor
        textColor = aDecoder.decodeObjectForKey(textColorKey) as! UIColor
        font = aDecoder.decodeObjectForKey(fontKey) as! UIFont
        alignment = NSTextAlignment(rawValue: Int(aDecoder.decodeIntForKey(alignmentKey)))!
        super.init(coder: aDecoder)
    }

    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(text, forKey: textKey)
        aCoder.encodeObject(backgroundColor, forKey: backgroundColorKey)
        aCoder.encodeObject(textColor, forKey: textColorKey)
        aCoder.encodeObject(font, forKey: fontKey)
        aCoder.encodeInt(Int32(alignment.rawValue), forKey: alignmentKey)
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
        
        if layer.backgroundColor != backgroundColor {
            return false
        }
        
        if layer.textColor != textColor {
            return false
        }
        
        if layer.font != font {
            return false
        }
        
        if layer.alignment != alignment {
            return false
        }

        return layer.text == self.text
    }

}