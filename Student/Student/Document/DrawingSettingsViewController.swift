//
//  DrawingSettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DrawingSettings: NSObject {

    static let sharedInstance = DrawingSettings()
    var lineWidth:CGFloat = 2
    var color = UIColor.blackColor()
}

protocol DrawingSettingsDelegate {
    func clearDrawing()
    
}

class DrawingSettingsViewController: SettingsBaseViewController {
    
    static var delegate: DrawingSettingsDelegate?
    
    @IBOutlet weak var lineWidthSlider: UISlider!
   
    // MARK: - Actions
    
    @IBAction func handleLineWidthValueChanged(sender: UISlider) {
        DrawingSettings.sharedInstance.lineWidth = CGFloat(sender.value)
    }
    
    @IBAction func handleEraseButtonPressed(sender: AnyObject) {
        DrawingSettings.sharedInstance.color = UIColor.clearColor()
    }
    
    @IBAction func handleClearButtonPressed(sender: AnyObject) {
        DrawingSettingsViewController.delegate?.clearDrawing()
    }

    // MARK: - ColorPickerDelegate 
    
    override func didSelectColor(color: UIColor) {
        DrawingSettings.sharedInstance.color = color
    }
}
