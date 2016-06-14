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
    func didSelectColor(_ colorPicker: ColorPickerViewController, color: UIColor)
    func canSelectClearColor(_ colorPicker: ColorPickerViewController) -> Bool
    @objc optional func setupColorPicker(_ colorPicker: ColorPickerViewController)
}

class ColorPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    struct ColorPickerElement {
        var pickerColor : UIColor?
        var resultColor : UIColor
    }
    
    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    private let allColors = [ColorPickerElement(pickerColor: UIColor.clearColorPattern(), resultColor: UIColor.clear()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.black()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNAsbestonsColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNConcreteColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNSilverColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNCloudsColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.white()),
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
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.orange()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.SunFlowerColor()),
                  ColorPickerElement(pickerColor: nil, resultColor: UIColor.PNYellowColor())]
    
    private var colors : [ColorPickerElement] {
        get {
            if delegate?.canSelectClearColor(self) ?? true {
                return allColors
            } else {
                return allColors.filter({ (element) -> Bool in
                    return element.resultColor != .clear()
                })
            }
        }
    }
    
    private var selectedIndex = 0 {
        didSet {
            if oldValue != selectedIndex {
                let selectedIndexPath = IndexPath(item: self.selectedIndex, section: 0)
                UIView.performWithoutAnimation({
                    self.colorCollectionView.reloadItems(at: [selectedIndexPath, IndexPath(item: oldValue, section: 0)])
                    self.colorCollectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: true)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        shouldScrollToSelectedIndex = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldScrollToSelectedIndex {
            colorCollectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
            shouldScrollToSelectedIndex = false
        }
    }
    
    func setColorSelected(_ color: UIColor) {
        for (index, colorElement) in colors.enumerated() {
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorPickerCollectionViewCell.identifier, for: indexPath) as? ColorPickerCollectionViewCell
        let colorPickerElement = colors[(indexPath as NSIndexPath).row]
        cell?.backgroundColor = colorPickerElement.pickerColor ?? colorPickerElement.resultColor
        cell?.isSelectedColor = (indexPath as NSIndexPath).row == selectedIndex

        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let isSelected = (indexPath as NSIndexPath).row == selectedIndex
        return CGSize(width: collectionView.bounds.height / (isSelected ? 1.35 : 1.5), height: collectionView.bounds.height / (isSelected ? 1.35 : 1.5))
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectColor(self, color: colors[(indexPath as NSIndexPath).row].resultColor)
        selectedIndex = (indexPath as NSIndexPath).row
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}
