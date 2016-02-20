//
//  DocumentExporter.swift
//  Student
//
//  Created by Leo Thomas on 10/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentExporter: NSObject {

    class func exportAsImages(document: Document, sourceView: UIView? = nil, barButtonItem: UIBarButtonItem? = nil) {
        var images = [UIImage]()
        for page in document.pages {
            let pageView = PageView(page: page)
            images.append(pageView.toImage())
        }

        let activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sourceView
        activityViewController.popoverPresentationController?.barButtonItem = barButtonItem
        UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentViewController(activityViewController, animated: true, completion: nil)
    }

    class func exportAsPDF(document: Document) {

    }

    class func exportAsProNote(document: Document) {

    }
}
