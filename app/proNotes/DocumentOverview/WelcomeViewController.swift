//
//  WelcomeViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 27/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var backLeftXConstraint: NSLayoutConstraint!
    @IBOutlet weak var backRightXConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleLeftXConstraint: NSLayoutConstraint!
    @IBOutlet weak var middleRightXConstraint: NSLayoutConstraint!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var hintLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for case let imageView as UIImageView in view.subviews {
            imageView.layer.setUpDefaultShaddow()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Preferences.setIsFirstRun(false)
        animateImageViews()
    }
    
    func animateImageViews() {
        view.layoutIfNeeded()
        let middleOffSet: CGFloat = topImageView.bounds.width/3.8
        middleLeftXConstraint.constant = -middleOffSet
        middleRightXConstraint.constant = middleOffSet
        let backOffset: CGFloat = topImageView.bounds.width/2.1
        backLeftXConstraint.constant = -backOffset
        backRightXConstraint.constant = backOffset
        UIView.animateWithDuration(1, delay: 0.2, options: .CurveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }

    @IBAction func handleContinueButtonPressed(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func handleNotifyButtonPressed(sender: UIButton) {
        sender.hidden = true
        hintLabel.hidden = true
        Preferences.setAllowsNotification(true)
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
    }
}
