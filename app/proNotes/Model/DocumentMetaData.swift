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
    var fileModificationDate: Date?
    
    override init() {
        super.init()
    }
    
    private let thumbImageKey = "thumbImage"

    required init(coder aDecoder: NSCoder) {
        if let imageData = aDecoder.decodeObject(forKey: thumbImageKey) as? Data {
            thumbImage = UIImage(data: imageData)
        }
    }

    func encode(with aCoder: NSCoder) {
        if let image = thumbImage, let imageData = UIImageJPEGRepresentation(image, 1.0) {
            aCoder.encode(imageData, forKey: thumbImageKey)
        }
    }
}
