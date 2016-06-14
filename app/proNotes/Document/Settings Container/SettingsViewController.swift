//
//  SettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func didChangeSettingsType(_ newType: SettingsViewControllerType)
}

enum SettingsViewControllerType: String {
    case Sketch = "SketchSettingsIdentifier"
    case Image = "ImageSettingsIdentifier"
    case PageInfo = "PageInfoSettingsIdentifier"
    case Text = "TextSettingsIdentifier"
}

class SettingsViewController: UIViewController {

    weak static var sharedInstance: SettingsViewController?
    weak var currentChildViewController: SettingsBaseViewController?
    weak var delegate: SettingsViewControllerDelegate?
    
    var currentSettingsType: SettingsViewControllerType = .PageInfo {
        didSet {
            if oldValue != currentSettingsType {
                setUpChildViewController(currentSettingsType)
                delegate?.didChangeSettingsType(currentSettingsType)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsViewController.sharedInstance = self
        setUpChildViewController(currentSettingsType)
        view.layer.setUpDefaultBorder()
    }

    private func setUpChildViewController(_ settingsViewController: SettingsViewControllerType) {
        self.currentChildViewController?.willMove(toParentViewController: nil)
        self.currentChildViewController?.view.removeFromSuperview()
        self.currentChildViewController?.removeFromParentViewController()

        self.currentChildViewController = UIStoryboard.documentSettingsContainerStoryBoard().instantiateViewController(withIdentifier: settingsViewController.rawValue) as? SettingsBaseViewController
        self.currentChildViewController!.view.frame = view.bounds
        self.addChildViewController(self.currentChildViewController!)
        self.view.addSubview(self.currentChildViewController!.view)
        self.currentChildViewController!.view.layoutIfNeeded()
        self.currentChildViewController?.didMove(toParentViewController: self)
    }

}
