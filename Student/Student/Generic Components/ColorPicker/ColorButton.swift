//
//  ColorButton.swift
//  Student
//
//  Created by Leo Thomas on 21/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@IBDesignable
class ColorButton: UIButton, ColorPickerDelegate {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    func setUp() {
        addTarget(self, action: "handleTouchUpInside", forControlEvents: .TouchUpInside)
    }

    func handleTouchUpInside() {
        showColorPicker()
    }
    
    func showColorPicker() {
        let viewController = ColorPickerViewController.getColorPicker()
        viewController.delegate = self
        viewController.view.frame = viewController.getRect()
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.modalPresentationStyle = .Popover
        if let popoverController = navigationController.popoverPresentationController {
            popoverController.sourceView = self
        }
        superview?.parentViewController?.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - ColorPickerDelegate
    
    func didSelectColor(color: UIColor) {
        backgroundColor = color
        sendActionsForControlEvents(.ValueChanged)
    }
}
