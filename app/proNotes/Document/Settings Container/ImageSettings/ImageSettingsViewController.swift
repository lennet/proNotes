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

    func getImage() -> UIImage

    func updateImage(image: UIImage)
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        update()
        cropImageView.layer.setUpDefaultShaddow()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateButtonVisibility(cropMode: Bool) {

        cancelButtonConstraint.constant = cropMode ? -cropButton.bounds.width : 0
        finishButtonConstraint.constant = cropMode ? cropButton.bounds.width : 0

        if cropMode {
            finishButton.hidden = false
            cancelButton.hidden = false
        } else {
            cropButton.hidden = true
            rotateLeftButton.hidden = true
            rotateRightButton.hidden = true
        }

        UIView.animateWithDuration(standardAnimationDuration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.view.layoutIfNeeded()
            self.finishButton.alpha = cropMode ? 1 : 0
            self.cancelButton.alpha = cropMode ? 1 : 0
            self.cropButton.alpha = cropMode ? 0 : 1
            self.rotateRightButton.alpha = cropMode ? 0 : 1
            self.rotateLeftButton.alpha = cropMode ? 0 : 1
        }, completion: {
            (Bool) -> Void in
            self.cropButton.hidden = cropMode
            self.rotateLeftButton.hidden = cropMode
            self.rotateRightButton.hidden = cropMode
            self.finishButton.hidden = !cropMode
            self.cancelButton.hidden = !cropMode

        })
    }

    func rotateImage(rotation: UIImageOrientation) {
        if let image = cropImageView.image?.rotateImage(rotation) {
            cropImageView.image = image
            ImageSettingsViewController.delegate?.updateImage(image)
        }
    }

    override func update() {
        cropImageView.image = ImageSettingsViewController.delegate?.getImage()
    }

    // MARK: - Actions

    @IBAction func handleDeleteButtonPressed(sender: AnyObject) {
        ImageSettingsViewController.delegate?.removeImage()
    }

    @IBAction func handleCancelButtonPressed(sender: AnyObject) {
        cropImageView.isEditing = false
        updateButtonVisibility(false)
    }

    @IBAction func handleRotateLeftButtonPressed(sender: AnyObject) {
        rotateImage(.Left)
    }

    @IBAction func handleRotateRightButtonPressed(sender: AnyObject) {
        rotateImage(.Right)
    }

    @IBAction func handleCropButtonPressed(sender: AnyObject) {
        cropImageView.isEditing = true
        updateButtonVisibility(true)
    }

    @IBAction func handleFinishButtonPressed(sender: AnyObject) {
        cropImageView.crop()
        updateButtonVisibility(false)
        if let image = cropImageView.image {
            ImageSettingsViewController.delegate?.updateImage(image)
        }
    }

}
