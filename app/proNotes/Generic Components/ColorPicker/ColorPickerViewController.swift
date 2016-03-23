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

    @IBOutlet weak var colorCollectionView: UICollectionView!

    let colors = [UIColor.blackColor(),
                  UIColor.darkGrayColor(),
                  UIColor.lightGrayColor(),
                  UIColor.whiteColor(),
                  UIColor.grayColor(),
                  UIColor.redColor(),
                  UIColor.greenColor(),
                  UIColor.blueColor(),
                  UIColor.cyanColor(),
                  UIColor.yellowColor(),
                  UIColor.magentaColor(),
                  UIColor.orangeColor(),
                  UIColor.purpleColor(),
                  UIColor.brownColor()]

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
        cell?.backgroundColor = colors[indexPath.row]
        cell?.isSelectedColor = indexPath.row == selectedIndex
        cell?.setNeedsDisplay()
        return cell!
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.height / 1.5, collectionView.bounds.height / 1.5)
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectColor(self, color: colors[indexPath.row])
        let lastSelectedIndex = selectedIndex
        selectedIndex = indexPath.row
        if lastSelectedIndex != lastSelectedIndex {
            collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: selectedIndex, inSection: 0), NSIndexPath(forItem: lastSelectedIndex, inSection: 0)])
        }
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
