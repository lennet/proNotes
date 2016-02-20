//
//  DrawingSettingsViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol DrawingSettingsDelegate: class {

    func clearDrawing()

    func didSelectColor(color: UIColor)

    func didSelectDrawingObject(object: DrawingObject)

    func removeLayer()
}

enum DrawingType {
    case Pen
    case Marker
    case Eraser
}

protocol DrawingObject: class {
    var color: UIColor { get set }
    var lineWidth: CGFloat { get set }
    var defaultAlphaValue: CGFloat? { get }
    var dynamicLineWidth: Bool { get }
    var enabledShading: Bool { get }
}

class Marker: DrawingObject {
    var color = UIColor.blueColor()
    var lineWidth: CGFloat = 20
    var defaultAlphaValue: CGFloat? = 0.5
    var dynamicLineWidth = true
    var enabledShading = true
}

class Eraser: DrawingObject {
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
    var enabledShading = false
}

class Pen: DrawingObject {
    var color = UIColor.blackColor()
    var lineWidth: CGFloat = 10
    var defaultAlphaValue: CGFloat? = 1
    var dynamicLineWidth = true
    var enabledShading = false
}

class DrawingSettingsViewController: SettingsBaseViewController {

    weak static var delegate: DrawingSettingsDelegate?

    let defaultTopConstant: CGFloat = -20
    let animationDuration = 0.2

    var currentType = DrawingType.Pen {
        didSet {
            if oldValue != currentType {

                switch oldValue {
                case .Pen:
                    penTopConstraint.constant = defaultTopConstant
                    break
                case .Marker:
                    markerTopConstraint.constant = defaultTopConstant
                    break
                case .Eraser:
                    eraserTopConstraint.constant = defaultTopConstant
                    break
                }

                var object: DrawingObject?

                switch currentType {
                case .Pen:
                    penTopConstraint.constant = 0
                    object = Pen()
                    break
                case .Marker:
                    markerTopConstraint.constant = 0
                    object = Marker()
                    break
                case .Eraser:
                    eraserTopConstraint.constant = 0
                    object = Eraser()
                    break
                }

                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
                    () -> Void in
                    self.view.layoutIfNeeded()
                }, completion: nil)

                DrawingSettingsViewController.delegate?.didSelectDrawingObject(object!)
            }
        }
    }

    @IBOutlet weak var penTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var markerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var eraserTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var lineWidthCircleView: CircleView!

    // MARK: - Actions

    @IBAction func handlePenButtonPressed(sender: AnyObject) {
        currentType = .Pen
    }

    @IBAction func handleMarkerButtonPressed(sender: AnyObject) {
        currentType = .Marker
    }

    @IBAction func handleEraserButtonPressed(sender: AnyObject) {
        currentType = .Eraser
    }

    @IBAction func handleClearButtonPressed(sender: AnyObject) {
        DrawingSettingsViewController.delegate?.clearDrawing()
    }

    @IBAction func handleDeleteButtonPressed(sender: AnyObject) {
        DrawingSettingsViewController.delegate?.removeLayer()
    }

    @IBAction func handleLineWidthSliderValueChanged(sender: UISlider) {
        lineWidthCircleView.radius = CGFloat(sender.value)
    }

    // MARK: - ColorPickerDelegate 

    override func didSelectColor(color: UIColor) {
        DrawingSettingsViewController.delegate?.didSelectColor(color)
    }
}
