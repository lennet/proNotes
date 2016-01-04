//
//  CustomScrollView.swift
//  Student
//
//  Created by Leo Thomas on 23/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {

    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        return false
    }

}
