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
    @IBOutlet weak var notifyButton: UIButton!
    
    static weak var sharedInstance: WelcomeViewController?
    
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
        if Preferences.AlreadyDownloadedDefaultNote() {
            alredyDownloaded = true
        }
        WelcomeViewController.sharedInstance = self
    }
    
    override func viewWillDisappear(animated: Bool) {
        WelcomeViewController.sharedInstance = nil
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
        Preferences.setShoudlShowWelcomeScreen(false)
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func handleNotifyButtonPressed(sender: UIButton) {
        if alredyDownloaded {
        
        } else {
            sender.hidden = true
            hintLabel.hidden = true
            Preferences.setAllowsNotification(true)
            UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        }
    }
    
    var alredyDownloaded: Bool = false {
        didSet {
            dispatch_async(dispatch_get_main_queue(),{
                if self.alredyDownloaded {
                    self.notifyButton.hidden = true
                    let attributedString = NSMutableAttributedString(string: "A sample Note has will be been downloaded via CloudKit")
                    
                    attributedString.addAttributes([NSStrikethroughStyleAttributeName: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue)], range: NSRange(location: 18, length: 7))
                    UIView.transitionWithView(self.hintLabel, duration: standardAnimationDuration, options: [.TransitionCrossDissolve], animations: {
                        self.hintLabel.attributedText = attributedString
                        }, completion: nil)
                    
                    
                }
                self.notifyButton.userInteractionEnabled = !self.alredyDownloaded
            })
        }
    }
}
