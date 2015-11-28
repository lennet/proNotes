//
//  DocumentViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController {

    var pagesOverviewController: PagesOverviewTableViewController?
    var pagesTableViewController: PagesTableViewController?

    let document = Document()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let url = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("test", ofType: "pdf")!) as CFURLRef
//        document.addPDF(url)
        pagesOverviewController?.pages = document.numberOfPages
        pagesTableViewController?.document = document
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleAddPageButtonPressed(sender: AnyObject) {
        pagesOverviewController?.addNewPage()
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? PagesOverviewTableViewController {
            pagesOverviewController = viewController
        } else if let viewController = segue.destinationViewController as? PagesTableViewController {
            pagesTableViewController = viewController
        }
    }
    

}
