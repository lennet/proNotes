//
//  TextSettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol TextSettingsDelegate {
    func removeText()
    func changeTextColor(color: UIColor)
    func changeBackgroundColor(color: UIColor)
    func changeAlignment(textAlignment: NSTextAlignment)
    func changeFont(font: UIFont)
    func disableAutoCorrect(disable: Bool)
}

class TextSettingsViewController: SettingsBaseViewController {

    static var delegate: TextSettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTextColorValueChanged(button: UIButton) {
        if let newColor = button.backgroundColor {
                TextSettingsViewController.delegate?.changeTextColor(newColor)
        }
    }

    @IBAction func handleBackgroundColorValueChanged(button: UIButton) {
        if let newColor = button.backgroundColor {
            TextSettingsViewController.delegate?.changeBackgroundColor(newColor)
        }
    }
    
    @IBAction func handleTextAlignmentValueChanged(control: UISegmentedControl) {
        if let textAlignment = NSTextAlignment(rawValue: control.selectedSegmentIndex) {
            TextSettingsViewController.delegate?.changeAlignment(textAlignment)
        }
    }
    
    @IBAction func handleAutoCorrectValueChanged(aSwitch: UISwitch) {
        TextSettingsViewController.delegate?.disableAutoCorrect(!aSwitch.on)
    }
}
