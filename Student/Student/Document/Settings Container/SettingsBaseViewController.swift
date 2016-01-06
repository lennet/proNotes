//
//  SettingsBaseViewController.swift
//  Student
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class SettingsBaseViewController: UIViewController, ColorPickerDelegate {

    var colorPickerViewController: ColorPickerViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    // MARK: - ColorPickerDelegate

    func didSelectColor(color: UIColor) {
        // empty base Implementation
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewContoller = segue.destinationViewController as? ColorPickerViewController {
            viewContoller.delegate = self
            colorPickerViewController = viewContoller
        }
    }


}
