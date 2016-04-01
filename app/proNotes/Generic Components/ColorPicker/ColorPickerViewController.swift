//
//  ColorPickerViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate: class {
    func didSelectColor(colorPicker: ColorPickerViewController, color: UIColor)
}

class ColorPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    struct ColorPickerElement {
        var pickerColor : UIColor?
        var resultColor : UIColor
    }
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    let colors = [ColorPickerElement(pickerColor: UIColor.clearColorPattern(), resultColor: UIColor.clearColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.blackColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.darkGrayColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.lightGrayColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.whiteColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.grayColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.redColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.greenColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.blueColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.cyanColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.yellowColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.magentaColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.orangeColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.purpleColor())]
    var selectedIndex = 0
    var identifier: String?
    
    
    weak var delegate: ColorPickerDelegate?

    static func getColorPicker() -> ColorPickerViewController {
        let storyboard = UIStoryboard.documentStoryboard()
        return storyboard.instantiateViewControllerWithIdentifier("ColorPickerViewControllerIdentifier") as! ColorPickerViewController
    }

    func getRect() -> CGRect {
        colorCollectionView.layoutIfNeeded()
        return colorCollectionView.bounds
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
        cell?.setNeedsDisplay()
        return cell!
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.height / 1.5, collectionView.bounds.height / 1.5)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectColor(self, color: colors[indexPath.row].resultColor)
        let lastSelectedIndex = selectedIndex
        selectedIndex = indexPath.row
        if lastSelectedIndex != lastSelectedIndex {
            collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: selectedIndex, inSection: 0), NSIndexPath(forItem: lastSelectedIndex, inSection: 0)])
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
