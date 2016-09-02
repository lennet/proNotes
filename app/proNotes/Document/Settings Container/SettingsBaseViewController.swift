//
//  SettingsBaseViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class SettingsBaseViewController: UIViewController, ColorPickerDelegate {

    weak var colorPicker: ColorPickerViewController?
    
    func update() {
        // empty base Implementation
    }

    // MARK: - ColorPickerDelegate

    func didSelectColor(_ colorPicker: ColorPickerViewController, color: UIColor) {
        // empty base Implementation
    }
    
    func canSelectClearColor(_ colorPicker: ColorPickerViewController) -> Bool {
        return true
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let colorPickerViewController = segue.destination as? ColorPickerViewController {
            colorPickerViewController.delegate = self
            colorPickerViewController.identifier = segue.identifier
            self.colorPicker = colorPickerViewController
        }
    }
}
