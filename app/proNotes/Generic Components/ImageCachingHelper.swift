//
//  ImageCachingHelper.swift
//  proNotes
//
//  Created by Leo Thomas on 26/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class ImageCachingHelper {

    
    class func storeImage(imageData: NSData) -> String? {
        let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
        let identifier = NSUUID().UUIDString
        let fileURL = tmpDirURL.URLByAppendingPathComponent(identifier).URLByAppendingPathExtension("jpg")
        guard let path = fileURL.path else {
            print("Saving Image to tmp dir failed because of missing path for url: \(fileURL)")
            return nil
        }
        do {
            try imageData.writeToFile(path, options: .AtomicWrite)
            return identifier
        } catch {
            print("Saving Image to tmp dir failed with error: \(error)")
            return nil
        }
    }
    
    class func getImage(identifier: String) -> UIImage? {
        let tmpDirURL = NSURL.fileURLWithPath(NSTemporaryDirectory(), isDirectory: true)
        let fileURL = tmpDirURL.URLByAppendingPathComponent(identifier).URLByAppendingPathExtension("jpg")
        guard let path = fileURL.path else {
            print("Load Image from tmp dir failed because of missing path for url: \(fileURL)")
            return nil
        }
        guard let data = NSData(contentsOfFile: path) else {
            print("Load Image from tmp dir failed because of missing broken data for url: \(fileURL)")
            return nil
        }
        
        return UIImage(data: data)
    }
    
    class func storeImageAsynchronous(imageData: NSData, completion: (identifier: String?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                () -> Void in
            completion(identifier: storeImage(imageData))
        }
    }
    
    class func getImageAsynchronous(identifier: String, completion: (image: UIImage?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            () -> Void in
            completion(image: getImage(identifier))
        }
    }
}
