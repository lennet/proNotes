//
//  SettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    weak static var sharedInstance: SettingsViewController?

    enum SettingsViewControllerType: String {
        case Sketch = "SketchSettingsIdentifier"
        case Image = "ImageSettingsIdentifier"
        case PageInfo = "PageInfoSettingsIdentifier"
        case Text = "TextSettingsIdentifier"
    }

    weak var currentChildViewController: SettingsBaseViewController?
    var currentSettingsType: SettingsViewControllerType = .PageInfo {
        didSet {
            if oldValue != currentSettingsType {
                setUpChildViewController(currentSettingsType)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsViewController.sharedInstance = self
        setUpChildViewController(currentSettingsType)
        view.layer.setUpDefaultBorder()
    }

    private func setUpChildViewController(settingsViewController: SettingsViewControllerType) {
        self.currentChildViewController?.willMoveToParentViewController(nil)
        self.currentChildViewController?.view.removeFromSuperview()
        self.currentChildViewController?.removeFromParentViewController()

        self.currentChildViewController = UIStoryboard.documentSettingsContainerStoryBoard().instantiateViewControllerWithIdentifier(settingsViewController.rawValue) as? SettingsBaseViewController
        self.currentChildViewController!.view.frame = view.bounds
        self.addChildViewController(self.currentChildViewController!)
        self.view.addSubview(self.currentChildViewController!.view)
        self.currentChildViewController!.view.layoutIfNeeded()
        self.currentChildViewController?.didMoveToParentViewController(self)
    }

}
