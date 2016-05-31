//
//  ImageCache.swift
//  proNotes
//
//  Created by Leo Thomas on 31/05/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import Foundation
import UIKit

class ImageCacheObject: NSObject {
    let image: UIImage
    let key: String
    init(image: UIImage, key: String) {
        self.image = image
        self.key = key
    }
}

class ImageCache: NSObject {
    
    static let sharedInstance = ImageCache()
    private let cache: NSCache

    
    subscript(key :String) -> UIImage? {
        get {
            if let imageCacheObject = cache.objectForKey(key) as? ImageCacheObject {
                return imageCacheObject.image
            }
            return loadImageFromDisk(key)
        }
        
        set {
            if let image = newValue {
                cache.setObject(ImageCacheObject(image: image, key: key), forKey: key)
            }
        }
    }
    
    private override init() {
        cache = NSCache()
        super.init()
        cache.delegate = self
    }
    
    private func loadImageFromDisk(key: String) -> UIImage? {
        let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(key).absoluteString
        
        guard let image = UIImage(contentsOfFile: fullPath) else {
            return nil
        }
        
        cache.setObject(image, forKey: key)
        return image
    }
    
    private func storeImageToDisk(image: UIImage, key: String) {
        let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(key).absoluteString
        let data = UIImageJPEGRepresentation(image, 1)
        NSFileManager.defaultManager().createFileAtPath(fullPath, contents: data, attributes: nil)
    }
    
}

extension ImageCache: NSCacheDelegate {
   
    func cache(cache: NSCache, willEvictObject obj: AnyObject) {
        if let imageCacheObject = obj as? ImageCacheObject {
            storeImageToDisk(imageCacheObject.image, key: imageCacheObject.key)
        }
    }
    
}