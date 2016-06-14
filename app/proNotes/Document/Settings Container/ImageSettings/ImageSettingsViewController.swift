//
//  ImageSettingsViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol ImageSettingsDelegate: class {
    func removeImage()

    func getImage() -> UIImage?

    func updateImage(_ image: UIImage)
}

class ImageSettingsViewController: SettingsBaseViewController {

    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cropImageView: CropImageView!

    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var rotateRightButton: UIButton!
    @IBOutlet weak var rotateLeftButton: UIButton!
    @IBOutlet weak var cancelButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var finishButtonConstraint: NSLayoutConstraint!

    static weak var delegate: ImageSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cropImageView.animateLayoutChanges = false
        update()
        cropImageView.layer.setUpDefaultShaddow()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cropImageView.animateLayoutChanges = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateButtonVisibility(_ cropMode: Bool) {

        cancelButtonConstraint.constant = cropMode ? -cropButton.bounds.width : 0
        finishButtonConstraint.constant = cropMode ? cropButton.bounds.width : 0

        if cropMode {
            finishButton.isHidden = false
            cancelButton.isHidden = false
        } else {
            cropButton.isHidden = true
            rotateLeftButton.isHidden = true
            rotateRightButton.isHidden = true
        }

        UIView.animate(withDuration: standardAnimationDuration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: UIViewAnimationOptions(), animations: {
            () -> Void in
            self.view.layoutIfNeeded()
            self.finishButton.alpha = cropMode ? 1 : 0
            self.cancelButton.alpha = cropMode ? 1 : 0
            self.cropButton.alpha = cropMode ? 0 : 1
            self.rotateRightButton.alpha = cropMode ? 0 : 1
            self.rotateLeftButton.alpha = cropMode ? 0 : 1
        }, completion: {
            (Bool) -> Void in
            self.cropButton.isHidden = cropMode
            self.rotateLeftButton.isHidden = cropMode
            self.rotateRightButton.isHidden = cropMode
            self.finishButton.isHidden = !cropMode
            self.cancelButton.isHidden = !cropMode

        })
    }

    func rotateImage(_ rotation: UIImageOrientation) {
        if let image = cropImageView.image?.rotateImage(rotation) {
            cropImageView.image = image
            ImageSettingsViewController.delegate?.updateImage(image)
        }
    }

    override func update() {
        cropImageView.image = ImageSettingsViewController.delegate?.getImage()
    }

    // MARK: - Actions

    @IBAction func handleDeleteButtonPressed(_ sender: AnyObject) {
        ImageSettingsViewController.delegate?.removeImage()
    }

    @IBAction func handleCancelButtonPressed(_ sender: AnyObject) {
        cropImageView.isEditing = false
        updateButtonVisibility(false)
    }

    @IBAction func handleRotateLeftButtonPressed(_ sender: AnyObject) {
        rotateImage(.left)
    }

    @IBAction func handleRotateRightButtonPressed(_ sender: AnyObject) {
        rotateImage(.right)
    }

    @IBAction func handleCropButtonPressed(_ sender: AnyObject) {
        cropImageView.isEditing = true
        updateButtonVisibility(true)
    }

    @IBAction func handleFinishButtonPressed(_ sender: AnyObject) {
        cropImageView.crop()
        updateButtonVisibility(false)
        if let image = cropImageView.image {
            ImageSettingsViewController.delegate?.updateImage(image)
        }
    }

}
