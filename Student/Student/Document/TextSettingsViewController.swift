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
    

    // MARK: - ColorPickerDelegate
    
    override func didSelectColor(color: UIColor) {
        TextSettingsViewController.delegate?.changeTextColor(color)
    }

}
