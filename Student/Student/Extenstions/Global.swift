//
//  Global.swift
//  Student
//
//  Created by Leo Thomas on 04/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

func between<T:Comparable>(value: T, min: T, max: T) -> T {
    if value < min {
        return min
    }

    if value > max {
        return max
    }

    return value
}