//
//  DocumentExporter.swift
//  Student
//
//  Created by Leo Thomas on 10/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentExporter: NSObject {

    class func exportAsImages(sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, viewController: UIViewController) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            () -> Void in
            guard let document = DocumentInstance.sharedInstance.document else {
                return
            }
            let images = getImageArrayForDocument(document)
            dispatch_async(dispatch_get_main_queue(),{
                presentActivityViewController(viewController, sourceView: sourceView, barbuttonItem: barButtonItem, items: images)
            })
        }
    }

    class func exportAsPDF(sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, viewController: UIViewController) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            () -> Void in
            guard let document = DocumentInstance.sharedInstance.document else {
                return
            }
            let mutableData = NSMutableData()
            let rect = CGRect(origin: CGPoint.zero, size: document.pages.first!.size)
            UIGraphicsBeginPDFContextToData(mutableData, rect, nil)
            let context = UIGraphicsGetCurrentContext()
            for image in getImageArrayForDocument(document) {
                let imageRect = CGRect(origin: CGPoint.zero, size: image.size)
                UIGraphicsBeginPDFPageWithInfo(imageRect, nil)
                CGContextDrawImage(context, imageRect, image.CGImage!)
            }
            UIGraphicsEndPDFContext()

            dispatch_async(dispatch_get_main_queue(),{
                presentActivityViewController(viewController, sourceView: sourceView, barbuttonItem: barButtonItem, items: [document.name, mutableData])
            })
        }
    }

    class func exportAsProNote(sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil, viewController: UIViewController) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            () -> Void in
            DocumentInstance.sharedInstance.save({ (_) in
                guard let document = DocumentInstance.sharedInstance.document else {
                    return
                }
                dispatch_async(dispatch_get_main_queue(),{
                    presentActivityViewController(viewController, sourceView: sourceView, barbuttonItem: barButtonItem, items: [document.fileURL])
                })
            })
        }
    }
    
    class func getImageArrayForDocument(document: Document) -> [UIImage] {
        var images = [UIImage]()
        for page in document.pages {
            let pageView = PageView(page: page, renderMode: true)
            images.append(pageView.toImage())
        }
        return images
    }
    
    class func presentActivityViewController(viewController: UIViewController, sourceView: UIView?, barbuttonItem: UIBarButtonItem?, items: [AnyObject] ) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.barButtonItem = barbuttonItem
        viewController.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
