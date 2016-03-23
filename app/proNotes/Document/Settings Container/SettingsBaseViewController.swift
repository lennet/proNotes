//
//  SettingsBaseViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class SettingsBaseViewController: UIViewController, ColorPickerDelegate {

    func update() {
        // empty base Implementation
    }

    // MARK: - ColorPickerDelegate

    func didSelectColor(colorPicker: ColorPickerViewController, color: UIColor) {
        // empty base Implementation
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let colorPickerViewController = segue.destinationViewController as? ColorPickerViewController {
            colorPickerViewController.delegate = self
            colorPickerViewController.identifier = segue.identifier
        }
    }
}
