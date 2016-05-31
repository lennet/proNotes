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
    private let cache: Cache<ImageCacheObject>

    subscript(key :String) -> UIImage? {
        get {
            if let imageCacheObject = cache[key] {
                return imageCacheObject.image
            }
            if let image = loadImageFromDisk(key) {
                cache[key] = ImageCacheObject(image: image, key: key)
            }
            return nil
        }
        
        set {
            if let image = newValue {
                cache[key] = ImageCacheObject(image: image, key: key)
            }
        }
    }
    
    private override init() {
        cache = Cache()
        super.init()
        cache.countLimit = 20
        cache.delegate = self
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    private func loadImageFromDisk(key: String) -> UIImage? {
        let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(key).absoluteString
        
        guard let image = UIImage(contentsOfFile: fullPath) else {
            return nil
        }
        
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