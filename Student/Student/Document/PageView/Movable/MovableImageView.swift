//
//  MovableImageView.swift
//  Student
//
//  Created by Leo Thomas on 06/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovableImageView: MovableView, ImageSettingsDelegate {

    var image: UIImage
    weak var imageView: UIImageView?

    init(image: UIImage, frame: CGRect, movableLayer: MovableLayer) {
        self.image = image
        super.init(frame: frame, movableLayer: movableLayer)
        proportionalResize = true
    }

    required init?(coder aDecoder: NSCoder) {
        self.image = UIImage()
        super.init(coder: aDecoder)
        proportionalResize = true
    }

    func setUpImageView() {
        clipsToBounds = true

        let imageView = UIImageView()
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
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

    func getImage() -> UIImage {
        return image
    }

    func redoImage(image: UIImage) {
        updateImage(image)
        if SettingsViewController.sharedInstance?.currentSettingsType == .Image {
            SettingsViewController.sharedInstance?.currentChildViewController?.update()
        }
    }
    

    func updateImage(image: UIImage) {
        guard imageView != nil else {
            return
        }
        undoManager?.prepareWithInvocationTarget(self).redoImage(self.image)
        let heightRatio = imageView!.bounds.height / self.image.size.height
        let widthRatio = imageView!.bounds.width / self.image.size.width
        imageView?.image = image

        if let imageLayer = movableLayer as? ImageLayer {
            imageLayer.image = image
        }

        self.image = image
        frame.size.height = (image.size.height * heightRatio) + 2 * controlLength
        frame.size.width = (image.size.width * widthRatio) + 2 * controlLength
        movableLayer?.size = frame.size

        saveChanges()
    }

}
