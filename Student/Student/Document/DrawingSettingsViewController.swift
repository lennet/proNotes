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
    // todo add delegate!
}

class DrawingSettingsViewController: UIViewController {
    
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
    
    @IBAction func handleGreenButtonPressed(sender: AnyObject) {
        DrawingSettings.sharedInstance.color = UIColor.greenColor().colorWithAlphaComponent(0.2)
    }
    
    @IBAction func handleBlackButtonPressed(sender: AnyObject) {
        DrawingSettings.sharedInstance.color = UIColor.blackColor()
    }
    
    @IBAction func handleRedButtonPressed(sender: AnyObject) {
        DrawingSettings.sharedInstance.color = UIColor.redColor()
    }
    
    @IBAction func handleBlueButtonPressed(sender: AnyObject) {
        DrawingSettings.sharedInstance.color = UIColor.blueColor()
    }
    
    @IBAction func handleEraseButtonPressed(sender: AnyObject) {
        DrawingSettings.sharedInstance.color = UIColor.clearColor()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
