//
//  ImageSettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol ImageSettingsDelegate {
    func removeImage()
    func getImage() -> UIImage
}

class ImageSettingsViewController: UIViewController {
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropImageView: CropImageView!
    static var delegate: ImageSettingsDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let image = ImageSettingsViewController.delegate?.getImage() {
            cropImageView.layoutIfNeeded()
            let ratio = cropImageView.bounds.width/image.size.width
            cropImageView.image = image
            imageViewHeightConstraint.constant = image.size.height * ratio
        }
        cropImageView.layer.setUpDefaultShaddow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func handleDeleteButtonPressed(sender: AnyObject) {
        ImageSettingsViewController.delegate?.removeImage()
    }

    @IBAction func handleCropButtonPressed(sender: AnyObject) {
        cropImageView.isCropping = true
    }

}
