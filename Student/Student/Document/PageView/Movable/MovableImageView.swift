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
    var imageView = UIImageView()

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
        imageView = UIImageView()

        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = falsej
        addSubview(imageView)
        addAutoLayoutConstraints(imageView)
    }

    override func setUpSettingsViewController() {
        ImageSettingsViewController.delegate = self
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Image
    }

    // MARK: - ImageSettingsDelegate

    func removeImage() {
        removeFromSuperview()
        movableLayer?.removeFromPage()
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .PageInfo
    }

    func getImage() -> UIImage {
        return image
    }
    
    func updateImage(image: UIImage) {
        let heightRatio = imageView.bounds.height/self.image.size.height
        let widthRatio = imageView.bounds.width/self.image.size.height
        imageView.image = image
        
        if let imageLayer = movableLayer as? ImageLayer {
            imageLayer.image = image
        }
        
        self.image = image
        // TODO something is going wrong here !
        frame.size.height = (imageView.bounds.height*heightRatio)+2*touchSize
        frame.size.width = (imageView.bounds.width*widthRatio)+2*touchSize
        movableLayer?.size = frame.size
        saveChanges()

    }

}
