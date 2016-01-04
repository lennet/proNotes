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
    
    init(image: UIImage, frame: CGRect, movableLayer: MovableLayer) {
        self.image = image
        super.init(frame: frame, movableLayer: movableLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.image = UIImage()
        super.init(coder: aDecoder)
    }
    
    func setUpImageView() {
        clipsToBounds = true
        let imageView = UIImageView()

        imageView.image = image
//        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        addAutoLayoutConstraints(imageView)
    }
    
    override func setUpSettingsViewController() {
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Image
        ImageSettingsViewController.delegate = self
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

}
