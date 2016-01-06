//
//  PlotSettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol PlotSettingsDelegate {
    func updatePlot(function: String)
}

class PlotSettingsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!

    static var delegate: PlotSettingsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if let text = textField.text {
            PlotSettingsViewController.delegate?.updatePlot(text)
        }
        textField.resignFirstResponder()
        return true
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
