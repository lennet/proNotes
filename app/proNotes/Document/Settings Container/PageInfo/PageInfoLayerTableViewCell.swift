//
//  PageInfoLayerTableViewCell.swift
//  proNotes
//
//  Created by Leo Thomas on 11/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol PageInfoLayerTableViewCellDelegate: class {
    func didRemovedLayer()
}

class PageInfoLayerTableViewCell: UITableViewCell {

    static let identifier = "PageInfoLayerTableViewCellIdentifier"

    @IBOutlet weak var visibilityButton: UIButton!
    @IBOutlet weak var indexLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!

    weak var documentLayer: DocumentLayer?
    weak var delegate: PageInfoLayerTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpCellWithLayer(_ documentLayer: DocumentLayer) {
        self.documentLayer = documentLayer
        indexLabel.text = String(documentLayer.index + 1)
        typeLabel.text = String(documentLayer.type)

        updateVisibilityButton()
    }
    
    func updateVisibilityButton() {
        guard documentLayer != nil else {
            return
        }
        let buttonImageName = documentLayer!.hidden ? "invisibleIcon" : "visibleIcon"
        UIView.animate(withDuration: standardAnimationDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            () -> Void in
                self.visibilityButton.setImage(UIImage(named: buttonImageName), for: UIControlState())
            }, completion: nil)
    }

    // MARK: - Actions

    @IBAction func handleDeleteButtonPressed(_ sender: AnyObject) {
        if documentLayer != nil {
            let index = documentLayer!.docPage.index
            PagesTableViewController.sharedInstance?.currentPageView?.removeLayer(documentLayer!)
            delegate?.didRemovedLayer()
            DocumentInstance.sharedInstance.didUpdatePage(index)
        }
    }

    @IBAction func handleVisibilityButtonPressed(_ sender: AnyObject) {
        if documentLayer != nil {
            let index = documentLayer!.docPage.index
            PagesTableViewController.sharedInstance?.currentPageView?.changeLayerVisibility(documentLayer!)
            updateVisibilityButton()
            DocumentInstance.sharedInstance.didUpdatePage(index)
        }

    }

}
