//
//  PageSubView.swift
//  proNotes
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@objc
protocol PageSubView: class {

    @objc optional func saveChanges()

    @objc optional func handlePan(_ panGestureRecognizer: UIPanGestureRecognizer)

    @objc optional func setSelected()

    @objc optional func setDeselected()

    @objc optional func setUpSettingsViewController()

    @objc optional func undoAction(_ oldObject: AnyObject?)

}
