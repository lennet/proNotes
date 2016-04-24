//
//  ColorPickerViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

@objc
protocol ColorPickerDelegate: class {
    func didSelectColor(colorPicker: ColorPickerViewController, color: UIColor)
    func canSelectClearColor(colorPicker: ColorPickerViewController) -> Bool
    optional func setupColorPicker(colorPicker: ColorPickerViewController)
}

class ColorPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    struct ColorPickerElement {
        var pickerColor : UIColor?
        var resultColor : UIColor
    }
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    private let allColors = [ColorPickerElement(pickerColor: UIColor.clearColorPattern(), resultColor: UIColor.clearColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.blackColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNAsbestonsColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNConcreteColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNSilverColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNCloudsColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.whiteColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNMidnightBlueColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNWetAsphaltColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNAmethystColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNWisteriaColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNBelizeHoleColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNPeterRiverColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNNephritisColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNEmeraldColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNGreenSeaColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNTurqoiseColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNRedColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNPomegranateColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNRedColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNAlizarinColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNPumpkinColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNCarrotColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.orangeColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.SunFlowerColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNYellowColor())]
    
    private var colors : [ColorPickerElement] {
        get {
            if delegate?.canSelectClearColor(self) ?? true {
                return allColors
            } else {
                return allColors.filter({ (element) -> Bool in
                    return element.resultColor != .clearColor()
                })
            }
        }
    }
    
    private var selectedIndex = 0 {
        didSet {
            if oldValue != selectedIndex {
                let selectedIndexPath = NSIndexPath(forItem: self.selectedIndex, inSection: 0)
                UIView.performWithoutAnimation({
                    self.colorCollectionView.reloadItemsAtIndexPaths([selectedIndexPath, NSIndexPath(forItem: oldValue, inSection: 0)])
                    self.colorCollectionView.scrollToItemAtIndexPath(selectedIndexPath, atScrollPosition: .CenteredHorizontally, animated: true)
                })
                
            }
        }
    }
    
    private var shouldScrollToSelectedIndex = false
    
    var identifier: String?
    weak var delegate: ColorPickerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate?.setupColorPicker?(self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        shouldScrollToSelectedIndex = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldScrollToSelectedIndex {
            colorCollectionView.scrollToItemAtIndexPath(NSIndexPath(forItem: selectedIndex, inSection: 0), atScrollPosition: .CenteredHorizontally, animated: false)
            shouldScrollToSelectedIndex = false
        }
    }
    
    func setColorSelected(color: UIColor) {
        for (index, colorElement) in colors.enumerate() {
            if color == colorElement.resultColor {
                selectedIndex = index
                return
            }
        }
    }
    
    func getSelectedColor() -> UIColor {
        return colors[selectedIndex].resultColor
    }
    
    // MARK: - UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ColorPickerCollectionViewCell.identifier, forIndexPath: indexPath) as? ColorPickerCollectionViewCell
        let colorPickerElement = colors[indexPath.row]
        cell?.backgroundColor = colorPickerElement.pickerColor ?? colorPickerElement.resultColor
        cell?.isSelectedColor = indexPath.row == selectedIndex

        return cell!
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let isSelected = indexPath.row == selectedIndex
        return CGSizeMake(collectionView.bounds.height / (isSelected ? 1.35 : 1.5), collectionView.bounds.height / (isSelected ? 1.35 : 1.5))
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectColor(self, color: colors[indexPath.row].resultColor)
        selectedIndex = indexPath.row
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
