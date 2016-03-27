//
//  PenProtocoll.swift
//  proNotes
//
//  Created by Leo Thomas on 27/03/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit

protocol Pen: class {
    var color: UIColor { get set }
    var lineWidth: CGFloat { get set }
    var defaultAlphaValue: CGFloat? { get }
    var dynamicLineWidth: Bool { get }
    var enabledShading: Bool { get }
    var isEraser: Bool { get }
}

class Pencil: Pen {
    var color = UIColor.blackColor()
    var lineWidth: CGFloat = 10
    var defaultAlphaValue: CGFloat? = 1
    var dynamicLineWidth = true
    var enabledShading: Bool = false
    var isEraser: Bool = false
}

class Marker: Pen {
    var color = UIColor.blueColor()
    var lineWidth: CGFloat = 20
    var defaultAlphaValue: CGFloat? = 0.5
    var dynamicLineWidth = true
    var enabledShading = true
    var isEraser: Bool = false
}

class Eraser: Pen {
    var color: UIColor {
        get {
            return .clearColor()
        }
        set {
            return
        }
    }
    var lineWidth: CGFloat = 10
    var defaultAlphaValue: CGFloat? = 1
    var dynamicLineWidth = false
    var isEraser: Bool = true
    var enabledShading: Bool = false
}