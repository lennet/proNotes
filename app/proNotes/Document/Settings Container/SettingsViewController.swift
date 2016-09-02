//
//  SettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol SettingsViewControllerDelegate: class {
    func didChangeSettingsType(to newType: SettingsType)
}

enum SettingsType {
    
    case sketch
    case image
    case pageInfo
    case text
    
    var viewController: SettingsBaseViewController {
        var identifier = ""
        switch  self {
        case .sketch:
            identifier = "SketchSettingsIdentifier"
            break
        case .image:
            identifier = "ImageSettingsIdentifier"
            break
        case .pageInfo:
            identifier = "PageInfoSettingsIdentifier"
            break
        case .text:
            identifier = "TextSettingsIdentifier"
            break
        }
        
        return UIStoryboard.documentSettingsContainerStoryBoard().instantiateViewController(withIdentifier: identifier) as! SettingsBaseViewController
    }
}

class SettingsViewController: UIViewController {
    
    weak static var sharedInstance: SettingsViewController?
    weak var currentChildViewController: SettingsBaseViewController?
    weak var delegate: SettingsViewControllerDelegate?
    
    var currentType: SettingsType = .pageInfo {
        didSet {
            if oldValue != currentType {
                setUpChildViewController(for: currentType)
                delegate?.didChangeSettingsType(to: currentType)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingsViewController.sharedInstance = self
        setUpChildViewController(for: currentType)
        view.layer.setUpDefaultBorder()
    }
    
    private func setUpChildViewController(for type: SettingsType) {
        self.currentChildViewController?.willMove(toParentViewController: nil)
        self.currentChildViewController?.view.removeFromSuperview()
        self.currentChildViewController?.removeFromParentViewController()
        
        self.currentChildViewController = type.viewController
        self.currentChildViewController!.view.frame = view.bounds
        self.addChildViewController(self.currentChildViewController!)
        self.view.addSubview(self.currentChildViewController!.view)
        self.currentChildViewController!.view.layoutIfNeeded()
        self.currentChildViewController?.didMove(toParentViewController: self)
    }
    
}
