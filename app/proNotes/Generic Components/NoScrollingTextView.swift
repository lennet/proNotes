//
//  NoScrollingTextView.swift
//  proNotes
//
//  Created by Leo Thomas on 26/03/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class NoScrollingTextView: UITextView {

    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        // Easy workaround to disable Scrolling without seting scrollEnabled to false (contentSize still available)
    }
    
}
