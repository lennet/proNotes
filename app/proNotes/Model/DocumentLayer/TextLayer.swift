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
    
    var text: String {
        didSet {
            // only ovverride automated generated names
            if (name == String(type) || oldValue.contains(name)) && !text.isEmpty {
                name = text
            }
        }
    }
    
    override var name: String {
        didSet {
            guard name.isEmpty else { return }
            name = text.isEmpty ? String(type) : text            
        }
    }
    
    var backgroundColor: UIColor
    var textColor: UIColor
    var font: UIFont
    var alignment: NSTextAlignment
    

    init(index: Int, docPage: DocumentPage, origin: CGPoint, size: CGSize, text: String) {
        self.text = text
        self.backgroundColor = UIColor.clear
        self.textColor = UIColor.black
        self.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        self.alignment = .left
        super.init(index: index, type: .text, docPage: docPage, origin: origin, size: size)
    }

    required init(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObject(forKey: textKey) as! String
        backgroundColor = aDecoder.decodeObject(forKey: backgroundColorKey) as! UIColor
        textColor = aDecoder.decodeObject(forKey: textColorKey) as! UIColor
        font = aDecoder.decodeObject(forKey: fontKey) as! UIFont
        alignment = NSTextAlignment(rawValue: Int(aDecoder.decodeInteger(forKey:alignmentKey)))!
        super.init(coder: aDecoder, type: .text)
    }
    
    required init(coder aDecoder: NSCoder, type: DocumentLayerType) {
        fatalError("init(coder:type:) has not been implemented")
    }

    override func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: textKey)
        aCoder.encode(backgroundColor, forKey: backgroundColorKey)
        aCoder.encode(textColor, forKey: textColorKey)
        aCoder.encode(font, forKey: fontKey)
        aCoder.encode(Int32(alignment.rawValue), forKey: alignmentKey)
        super.encode(with: aCoder)
    }

    override func undoAction(_ oldObject: AnyObject?) {
        if let text = oldObject as? String {
            self.text = text
        } else {
            super.undoAction(oldObject)
        }
    }

    override func isEqual(_ object: AnyObject?) -> Bool {
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
