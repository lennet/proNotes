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

    func didSelectColor(_ color: UIColor)

    func didSelectDrawingObject(_ object: Pen)

    func didSelectLineWidth(_ width: CGFloat)
    
    func removeLayer()
}

enum SketchType {
    case pen
    case marker
    case eraser
}

class SketchSettingsViewController: SettingsBaseViewController {

    weak static var delegate: SketchSettingsDelegate?

    let defaultTopConstant: CGFloat = -20

    var currentType = SketchType.pen {
        didSet {
            if oldValue != currentType {

                switch oldValue {
                case .pen:
                    penTopConstraint.constant = defaultTopConstant
                    break
                case .marker:
                    markerTopConstraint.constant = defaultTopConstant
                    break
                case .eraser:
                    eraserTopConstraint.constant = defaultTopConstant
                    break
                }

                var object: Pen?
                
                
                // -1 instead of 0 to avoid whitespaces during spring animation
                switch currentType {
                case .pen:
                    penTopConstraint.constant = -1
                    object = Pencil()
                    break
                case .marker:
                    markerTopConstraint.constant = -1
                    object = Marker()
                    break
                case .eraser:
                    eraserTopConstraint.constant = -1
                    object = Eraser()
                    break
                }

                UIView.animate(withDuration: standardAnimationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5, options: UIViewAnimationOptions(), animations: {
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

    @IBAction func handlePenButtonPressed(_ sender: AnyObject) {
        currentType = .pen
    }

    @IBAction func handleMarkerButtonPressed(_ sender: AnyObject) {
        currentType = .marker
    }

    @IBAction func handleEraserButtonPressed(_ sender: AnyObject) {
        currentType = .eraser
    }

    @IBAction func handleClearButtonPressed(_ sender: AnyObject) {
        SketchSettingsViewController.delegate?.clearSketch() 
    }

    @IBAction func handleDeleteButtonPressed(_ sender: AnyObject) {
        SketchSettingsViewController.delegate?.removeLayer()
    }

    @IBAction func handleLineWidthSliderValueChanged(_ sender: UISlider) {
        lineWidthCircleView.radius = CGFloat(sender.value)
        SketchSettingsViewController.delegate?.didSelectLineWidth(lineWidthCircleView.radius)
    }

    // MARK: - ColorPickerDelegate 

    override func didSelectColor(_ colorPicker: ColorPickerViewController, color: UIColor) {
        SketchSettingsViewController.delegate?.didSelectColor(color)
    }
    
    override func canSelectClearColor(_ colorPicker: ColorPickerViewController) -> Bool {
        return false
    }
}
