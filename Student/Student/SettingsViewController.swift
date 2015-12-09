//
//  SettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    enum SettingsViewController: String {
        case Drawing = "DrawingSettingsIdentifier"
        case Image = "ImageSettingsIdentifier"
        case PageInfo = "PageInfoSettingsIdentifier"
    }
    
    var currentChildViewController: UIViewController?
    var currentSettingsType: SettingsViewController = .PageInfo {
        didSet{
            if oldValue != currentSettingsType {
                setUpChildViewController(currentSettingsType)
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DocumentSynchronizer.sharedInstance.settingsViewController = self
        setUpChildViewController(currentSettingsType)
        view.backgroundColor = UIColor.yellowColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpChildViewController(settingsViewController: SettingsViewController) {
        // TODO Animate!
        self.currentChildViewController?.removeFromParentViewController()
        self.currentChildViewController = UIStoryboard.documentStoryboard().instantiateViewControllerWithIdentifier(settingsViewController.rawValue)
        self.addChildViewController(self.currentChildViewController!)
        self.view.addSubview(self.currentChildViewController!.view)
        self.currentChildViewController?.didMoveToParentViewController(self)
    }

}
