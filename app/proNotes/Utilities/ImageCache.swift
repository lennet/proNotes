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
    private let cache: NSCache<NSString, UIImage>

    subscript(key :String) -> UIImage? {
        get {
            if let image = cache.object(forKey: key as NSString) {
                return image
            }
            if let image = loadImageFromDisk(key: key) {
                cache.setObject(image, forKey: key as NSString)
                return image
            }
            return nil
        }
        
        set {
            if let image = newValue {
                cache.setObject(image, forKey: key as NSString)
            }
        }
    }
    
    private override init() {
        cache = NSCache()
        super.init()
        cache.countLimit = 20
        cache.delegate = self
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    private func loadImageFromDisk(key: String) -> UIImage? {
        guard let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key)?.absoluteString else { return nil }
        
        guard let image = UIImage(contentsOfFile: fullPath) else {
            return nil
        }
        
        return image
    }
    
    func storeImageToDisk(image: UIImage, key: String) {
        guard let fullPath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(key)?.absoluteString else { return }
        let data = UIImageJPEGRepresentation(image, 1)
        FileManager.default.createFile(atPath: fullPath, contents: data, attributes: nil)
    }
    
}

extension ImageCache: NSCacheDelegate {
   
    private func cache(cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: AnyObject) {
        if let imageCacheObject = obj as? ImageCacheObject {
            storeImageToDisk(image: imageCacheObject.image, key: imageCacheObject.key)
        }
    }
    
}
