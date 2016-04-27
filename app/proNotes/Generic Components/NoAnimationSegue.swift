//
//  NoAnimationSegue.swift
//  proNotes
//
//  Created by Leo Thomas on 27/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

class NoAnimationSegue: UIStoryboardSegue {

    override func perform() {
        sourceViewController.navigationController?.presentViewController(destinationViewController, animated: false, completion: nil)
    }
}
