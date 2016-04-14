//
//  SketchSettingsViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol SketchSettingsDelegate: class {

    func clearSketch()

    func didSelectColor(color: UIColor)

    func didSelectDrawingObject(object: Pen)

    func didSelectLineWidth(width: CGFloat)
    
    func removeLayer()
}

enum SketchType {
    case Pen
    case Marker
    case Eraser
}

class SketchSettingsViewController: SettingsBaseViewController {

    weak static var delegate: SketchSettingsDelegate?

    let defaultTopConstant: CGFloat = -20
    let animationDuration = 0.2

    var currentType = SketchType.Pen {
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
                
                
                // -1 instead of 0 to avoid whitespaces during spring animation
                switch currentType {
                case .Pen:
                    penTopConstraint.constant = -1
                    object = Pencil()
                    break
                case .Marker:
                    markerTopConstraint.constant = -1
                    object = Marker()
                    break
                case .Eraser:
                    eraserTopConstraint.constant = -1
                    object = Eraser()
                    break
                }

                UIView.animateWithDuration(animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
                    () -> Void in
                    self.lineWidthCircleView.radius = object?.lineWidth ?? self.lineWidthCircleView.radius
                    self.lineWidthSlider.value = Float(self.lineWidthCircleView.radius)
                    self.view.layoutIfNeeded()
                }, completion: nil)

                SketchSettingsViewController.delegate?.didSelectDrawingObject(object!)
            }
        }
    }

    @IBOutlet weak var penTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var markerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var eraserTopConstraint: NSLayoutConstraint!

    @IBOutlet weak var lineWidthSlider: UISlider!
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
        SketchSettingsViewController.delegate?.clearSketch() 
    }

    @IBAction func handleDeleteButtonPressed(sender: AnyObject) {
        SketchSettingsViewController.delegate?.removeLayer()
    }

    @IBAction func handleLineWidthSliderValueChanged(sender: UISlider) {
        lineWidthCircleView.radius = CGFloat(sender.value)
        SketchSettingsViewController.delegate?.didSelectLineWidth(lineWidthCircleView.radius)
    }

    // MARK: - ColorPickerDelegate 

    override func didSelectColor(colorPicker: ColorPickerViewController, color: UIColor) {
        SketchSettingsViewController.delegate?.didSelectColor(color)
    }
    
    override func canSelectClearColor(colorPicker: ColorPickerViewController) -> Bool {
        return false
    }
}
