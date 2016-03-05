//
//  Global.swift
//  proNotes
//
//  Created by Leo Thomas on 04/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

func between<T:Comparable>(value: T, min: T, max: T) -> T {
    if value < min {
        return min
    }

    if value > max {
        return max
    }

    return value
}

/**
 - From http://stackoverflow.com/a/31827999/5128083
   StackOverflow Author: http://stackoverflow.com/users/3542688/bat
 - returns: current MemoryUsage
*/

func getMemoryUsage() -> Int? {
    var size: mach_msg_type_number_t = mach_msg_type_number_t(sizeofValue(task_basic_info()))
    let pointerOfBasicInfo = UnsafeMutablePointer<task_basic_info>.alloc(1)
    
    let kerr = task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), UnsafeMutablePointer(pointerOfBasicInfo), &size)

    let info = pointerOfBasicInfo.move()
    pointerOfBasicInfo.dealloc(1)
    
    if kerr == KERN_SUCCESS {
        return Int(info.resident_size)
    } else {
        return nil
    }
}

let π = CGFloat(M_PI)
let standardAnimationDuration: Double = 0.2