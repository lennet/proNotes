//
//  3DTouchGestureRecognizer.swift
//  proNotes
//
//  Created by Leo Thomas on 30/04/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import AudioToolbox
import UIKit.UIGestureRecognizerSubclass


class DeepTouchGestureRecognizer: UIGestureRecognizer {
    
    var vibrate = false
    var forceValue: CGFloat = 0
    let threshold: CGFloat
    
    private var deepPressed: Bool = false
    
    required init(target: AnyObject?, action: Selector, threshold: CGFloat) {
        self.threshold = threshold
        super.init(target: target, action: action)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else {
            return
        }
        handleTouch(touch)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        guard let touch = touches.first else {
            return
        }
        handleTouch(touch)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = deepPressed ? .ended : .failed
        deepPressed = false
    }
    
    private func handleTouch(_ touch: UITouch) {
        guard touch.force != 0 && touch.maximumPossibleForce != 0 else {
            return
        }
        forceValue = touch.force / touch.maximumPossibleForce
        if !deepPressed && forceValue >= threshold {
            
            state = .began
            
            if vibrate {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
            
            deepPressed = true
        } else if deepPressed && (touch.force / touch.maximumPossibleForce) < threshold {
            state = UIGestureRecognizerState.ended
            
            deepPressed = false
        }
    }
}
