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

    func didSelectDrawingObject(object: Pen)

    func didSelectLineWidth(width: CGFloat)
    
    func removeLayer()
}

enum DrawingType {
    case Pen
    case Marker
    case Eraser
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

                var object: Pen?

                switch currentType {
                case .Pen:
                    penTopConstraint.constant = 0
                    object = Pencil()
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
        DrawingSettingsViewController.delegate?.didSelectLineWidth(lineWidthCircleView.radius)
    }

    // MARK: - ColorPickerDelegate 

    override func didSelectColor(colorPicker: ColorPickerViewController, color: UIColor) {
        DrawingSettingsViewController.delegate?.didSelectColor(color)
    }
}
