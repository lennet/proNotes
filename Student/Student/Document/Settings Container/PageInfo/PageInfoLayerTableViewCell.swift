//
//  PageInfoLayerTableViewCell.swift
//  Student
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PageInfoLayerTableViewCell: UITableViewCell {

    static let identifier = "PageInfoLayerTableViewCellIdentifier"

    @IBOutlet weak var visibilityButton: UIButton!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    var documentLayer: DocumentLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCellWithLayer(documentLayer: DocumentLayer){
        self.documentLayer = documentLayer
        indexLabel.text = String(documentLayer.index+1)
        typeLabel.text = String(documentLayer.type)
        
        let buttonImageName = documentLayer.hidden ? "invisibleIcon" : "visibleIcon"
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.visibilityButton.setImage(UIImage(named: buttonImageName), forState: .Normal)
            }, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func handleDeleteButtonPressed(sender: AnyObject) {
        if documentLayer != nil {
            PagesTableViewController.sharedInstance?.currentPageView()?.removeLayer(documentLayer!)
        }
    }
    
    @IBAction func handleVisibilityButtonPressed(sender: AnyObject) {
        if documentLayer != nil {
            PagesTableViewController.sharedInstance?.currentPageView()?.changeLayerVisibility(documentLayer!)
        }
        
    }
    
}
