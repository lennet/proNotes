//
//  MovableImageView.swift
//  proNotes
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableImageView: MovableView, ImageSettingsDelegate {

    weak var imageView: UIImageView?
    
    var imageLayer: ImageLayer?  {
        get {
            return movableLayer as? ImageLayer
        }
    }

    override init(frame: CGRect, movableLayer: MovableLayer, renderMode: Bool = false) {
        super.init(frame: frame, movableLayer: movableLayer, renderMode: renderMode)
        proportionalResize = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        proportionalResize = true
    }

    func setUpImageView() {
        clipsToBounds = true
        let imageView = UIImageView()
        imageView.image = imageLayer?.image
        addSubview(imageView)
        self.imageView = imageView
    }

    override func setUpSettingsViewController() {
        ImageSettingsViewController.delegate = self
        SettingsViewController.sharedInstance?.currentSettingsType = .Image
    }

    // MARK: - ImageSettingsDelegate

    func removeImage() {
        removeFromSuperview()
        movableLayer?.removeFromPage()
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }

    func getImage() -> UIImage? {
        return imageLayer?.image
    }

    override func undoAction(_ oldObject: Any?) {
        guard let image = oldObject as? UIImage else {
            super.undoAction(oldObject)
            return
        }

        updateImage(image)
        if SettingsViewController.sharedInstance?.currentSettingsType == .Image {
            SettingsViewController.sharedInstance?.currentChildViewController?.update()
        }
    }

    func updateImage(_ image: UIImage) {
        guard imageView != nil else {
            return
        }
        
        if let oldImage = imageLayer?.image {
            if movableLayer != nil && movableLayer?.docPage != nil {
                DocumentInstance.sharedInstance.registerUndoAction(oldImage, pageIndex: movableLayer!.docPage.index, layerIndex: movableLayer!.index)
            }
        }
        
        let heightRatio = imageView!.bounds.height / imageView!.image!.size.height
        let widthRatio = imageView!.bounds.width / imageView!.image!.size.width
        
        imageView?.image = image
        imageLayer?.image = image
        
        frame.size.height = (image.size.height * heightRatio) + controlLength
        frame.size.width = (image.size.width * widthRatio) + controlLength
        movableLayer?.size = frame.size
        layoutIfNeeded()
        setNeedsDisplay()
        saveChanges()
    }

}
