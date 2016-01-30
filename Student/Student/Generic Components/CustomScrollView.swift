//
//  CustomScrollView.swift
//  Student
//
//  Created by Leo Thomas on 23/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class CustomScrollView: UIScrollView {
    
    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(gestureRecognizer.isKindOfClass(UIPinchGestureRecognizer) && otherGestureRecognizer.isKindOfClass(UIPanGestureRecognizer))
    }
}
