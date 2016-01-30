//
//  PageSubView.swift
//  Student
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@objc
protocol PageSubView: class {

    
    optional func handlePan(panGestureRecognizer: UIPanGestureRecognizer)

    optional func handleTap(tapGestureRecognizer: UITapGestureRecognizer?)

    optional func handleDoubleTap(tapGestureRecognizer: UITapGestureRecognizer)

    optional func setSelected()

    optional func setDeselected()

    optional func saveChanges()

    optional func setUpSettingsViewController()
    
}
