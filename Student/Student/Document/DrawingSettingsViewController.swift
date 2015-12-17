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

class DrawingSettingsViewController: UIViewController, ColorPickerDelegate {
    
    static var delegate: DrawingSettingsDelegate?
    
    @IBOutlet weak var lineWidthSlider: UISlider!
    override func viewDidLoad() {


        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
    
    func didSelectColor(color: UIColor) {
        DrawingSettings.sharedInstance.color = color
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewContoller = segue.destinationViewController as? ColorPickerViewController {
            viewContoller.delegate = self
        }
    }


}
