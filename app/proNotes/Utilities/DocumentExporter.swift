//
//  DocumentExporter.swift
//  Student
//
//  Created by Leo Thomas on 10/02/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class DocumentExporter {
    
    class func exportAsImages(_ progress: (Float) -> Void) -> [UIImage] {
        guard let document = DocumentInstance.sharedInstance.document else {
            return []
        }
        let images = getImageArrayForDocument(document, progress: progress)
        return images
    }
    
    class func exportAsPDF(_ progress: (Float) -> Void) -> Data? {
        guard let document = DocumentInstance.sharedInstance.document,
            let size = document.pages.first?.size else {
            return nil
        }
        let mutableData = NSMutableData()
        
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginPDFContextToData(mutableData, rect, nil)
        let context = UIGraphicsGetCurrentContext()
        for image in getImageArrayForDocument(document, progress: progress) {
            let imageRect = CGRect(origin: .zero, size: image.size)
            UIGraphicsBeginPDFPageWithInfo(imageRect, nil)
            context?.draw(image.cgImage!, in: imageRect)
        }
        UIGraphicsEndPDFContext()
        return mutableData as Data
    }
    
    class func exportAsProNote(_ progress:  @escaping (Float) -> Void, url: @escaping (URL?) -> Void) {
        progress(0.5)
        DocumentInstance.sharedInstance.save({ (_) in
            progress(1)
            guard let document = DocumentInstance.sharedInstance.document else {
                url(nil)
                return
            }
            url(document.fileURL)
        })
        
    }
    
    class func getImageArrayForDocument(_ document: Document, progress: (Float) -> Void) -> [UIImage] {
        var images = [UIImage]()
        for (index, page) in document.pages.enumerated() {
            let pageView = PageView(page: page, renderMode: true)
            pageView.layoutIfNeeded()
            images.append(pageView.toImage())
            progress(Float(index+1)/Float(document.pages.count))
        }
        return images
    }
    
    class func presentActivityViewController(_ viewController: UIViewController, barbuttonItem: UIBarButtonItem?, items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = barbuttonItem
        viewController.present(activityViewController, animated: true, completion: nil)
        
    }
}
