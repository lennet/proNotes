//
//  CALayerExtension.swift
//  proNotes
//
//  Created by Leo Thomas on 24/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension CALayer {

    func setUpDefaultShaddow() {
        self.masksToBounds = false
        self.shadowOffset = CGSize(width: 0, height: 2)
        self.shadowRadius = 1.5
        self.shadowOpacity = 0.6
    }

    func setUpDefaultBorder() {
        self.masksToBounds = false
        self.shadowOffset = CGSize(width: -1, height: 0)
        self.shadowRadius = 1
        self.shadowOpacity = 1
    }

}
