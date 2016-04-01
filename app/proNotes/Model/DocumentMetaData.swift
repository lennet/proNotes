//
//  DocumentMetaData.swift
//  proNotes
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentMetaData: NSObject, NSCoding {

    var thumbImage: UIImage?
    var fileModificationDate: NSDate?
    
    override init() {
        super.init()
    }
    
    private let thumbImageKey = "thumbImage"

    required init(coder aDecoder: NSCoder) {
        if let imageData = aDecoder.decodeObjectForKey(thumbImageKey) as? NSData {
            thumbImage = UIImage(data: imageData)
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        if let image = thumbImage, let imageData = UIImageJPEGRepresentation(image, 1.0) {
            aCoder.encodeObject(imageData, forKey: thumbImageKey)
        }
    }
}
