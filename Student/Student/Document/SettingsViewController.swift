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
        case Text = "TextSettingsIdentifier"
        case Plot = "PlotSettingsIdentifier"
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpChildViewController(settingsViewController: SettingsViewController) {
//UIView.transitionFromView(<#T##fromView: UIView##UIView#>, toView: <#T##UIView#>, duration: <#T##NSTimeInterval#>, options: <#T##UIViewAnimationOptions#>, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
        // TODO Animate!
        self.currentChildViewController?.willMoveToParentViewController(nil)
        self.currentChildViewController?.view.removeFromSuperview()
        self.currentChildViewController?.removeFromParentViewController()

        self.currentChildViewController = UIStoryboard.documentStoryboard().instantiateViewControllerWithIdentifier(settingsViewController.rawValue)
        self.currentChildViewController!.view.frame = view.bounds
        self.addChildViewController(self.currentChildViewController!)
        self.view.addSubview(self.currentChildViewController!.view)
        self.currentChildViewController!.view.layoutIfNeeded()
        self.currentChildViewController?.didMoveToParentViewController(self)
    }

}
