//
//  NSURLExtension.swift
//  Student
//
//  Created by Leo Thomas on 17/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

extension NSURL {

    func fileName() -> String? {
        guard let lastPathComponent = URLByDeletingPathExtension?.lastPathComponent else {
            return nil
        }
        return lastPathComponent
    }
    
}
