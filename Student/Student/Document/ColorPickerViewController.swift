//
//  ColorPickerViewController.swift
//  Student
//
//  Created by Leo Thomas on 17/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol ColorPickerDelegate {
    func didSelectColor(color :UIColor)
}

class ColorPickerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var colorCollectionView: UICollectionView!
    
    let colors = [UIColor.blackColor(), UIColor.redColor(), UIColor.yellowColor(), UIColor.greenColor(), UIColor.purpleColor()]
    var selectedIndex = 0
    
    var delegate: ColorPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - UICollectionViewDatasource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ColorPickerCollectionViewCell.identifier, forIndexPath: indexPath) as? ColorPickerCollectionViewCell
        cell?.backgroundColor = colors[indexPath.row]
        cell?.isSelectedColor = indexPath.row == selectedIndex
        return cell!
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectColor(colors[indexPath.row])
        let lastSelectedIndex = selectedIndex
        selectedIndex = indexPath.row
        collectionView.reloadItemsAtIndexPaths([NSIndexPath(forItem: selectedIndex, inSection: 0), NSIndexPath(forItem: lastSelectedIndex, inSection: 0)])
    }

}
