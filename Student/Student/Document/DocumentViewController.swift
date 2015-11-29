//
//  DocumentViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController, PagesOverviewTableViewCellDelegate {

    var pagesOverviewController: PagesOverviewTableViewController?
    var pagesTableViewController: PagesTableViewController?

    var document: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("test", ofType: "pdf")!) as CFURLRef
//        document.addPDF(url)
        pagesOverviewController?.pages = document!.getNumberOfPages()
        pagesTableViewController?.document = document
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleAddPageButtonPressed(sender: AnyObject) {
        document?.addEmptyPage()
        pagesTableViewController?.document = document
        pagesOverviewController?.addNewPage()
    }

    @IBAction func handleDrawButtonPressed(sender: AnyObject) {
    
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? PagesOverviewTableViewController {
            viewController.pagesOverViewDelegate = self
            pagesOverviewController = viewController
        } else if let viewController = segue.destinationViewController as? PagesTableViewController {
            pagesTableViewController = viewController
        }
    }
    
    // MARK; - PagesOverViewDelegate 
    
    func showPage(index: Int){
        pagesTableViewController?.showPage(index)
    }
    

}
