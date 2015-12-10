//
//  UIStoryboardExtension.swift
//  Student
//
//  Created by Leo Thomas on 09/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

extension UIStoryboard {

    
    
    static func documentStoryboard() -> UIStoryboard {
        let documentStoryboardName = "Document"
        return UIStoryboard(name: documentStoryboardName, bundle: nil)
    }
}
