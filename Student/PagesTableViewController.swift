//
//  PagesTableViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class PagesTableViewController: UITableViewController {

   
    var document: Document? {
        didSet {
            loadTableView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 500.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.panGestureRecognizer.minimumNumberOfTouches = 1
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        loadTableView()
    }
    
    func loadTableView() {
        tableView.reloadData()
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showPage(pageNumber: Int){
        let indexPath = NSIndexPath(forRow: pageNumber, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return document?.getNumberOfPages() ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(PageTableViewCell.identifier, forIndexPath: indexPath) as! PageTableViewCell
        
        if let currentPage = document?.pages[indexPath.row] {
            cell.pageView.page = currentPage
            cell.pageView.pdfViewDelegate = cell
        }
        cell.layoutIfNeeded()
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
