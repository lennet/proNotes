//
//  DocumentOverviewTableViewController.swift
//  Student
//
//  Created by Leo Thomas on 29/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentOverviewTableViewController: UITableViewController, UIDocumentPickerDelegate {

    @IBAction func handleImportButtonPressed(sender: AnyObject) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["com.adobe.pdf"], inMode: .Import)
        documentPicker.delegate = self;
        documentPicker.modalPresentationStyle = .PageSheet
        self.presentViewController(documentPicker, animated: true, completion: nil)
//        performSegueWithIdentifier("test", sender: nil)
    }

    var urls = [NSURL]()

    override func viewDidLoad() {
        super.viewDidLoad()
        let documentUrl = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)

//        let fileExtension = String(NSDate().timeIntervalSinceReferenceDate) + "test.studentDoc"
//        let fileURL = documentUrl.URLByAppendingPathComponent(fileExtension)
//        let document = Document(fileURL: fileURL)
//        document.addEmptyPage()
//        document.saveToURL(fileURL, forSaveOperation: .ForCreating) { (success) -> Void in
//            document.savePresentedItemChangesWithCompletionHandler { (error) -> Void in
//                print(error)
//                print("save update")
//            }
//        }



        urls = try! NSFileManager.defaultManager().contentsOfDirectoryAtURL(documentUrl, includingPropertiesForKeys: nil, options: .SkipsHiddenFiles)



        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return urls.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        cell.textLabel?.text = urls[indexPath.row].pathComponents?.last
        do {
            let attr: NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(self.urls[indexPath.row].path!)

            if let _attr = attr {
                let fileSize = Int64(_attr.fileSize())

                let sizeString = NSByteCountFormatter.stringFromByteCount(fileSize, countStyle: .Binary)
                cell.detailTextLabel?.text = sizeString
            }
        } catch {
            print("Error: \(error)")
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = urls[indexPath.row]
        let document = Document(fileURL: url)
        document.openWithCompletionHandler {
            (success) -> Void in
            self.showDocument(document)
        }

    }


    func showDocument(document: Document) {
        print(document)
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


    // MARK: - Navigation


    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let cell = sender as? UITableViewCell {
            guard let indexPath = tableView.indexPathForCell(cell) else {
                return
            }
            let url = urls[indexPath.row]
            let document = Document(fileURL: url)
            document.openWithCompletionHandler({
                (success) -> Void in
                if success {
                    DocumentSynchronizer.sharedInstance.document = document
                }
            })
        }
    }

    @IBAction func handleNewButtonPressed(sender: AnyObject) {
        let documentUrl = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)

        let fileExtension = String(NSDate().timeIntervalSinceReferenceDate) + "test.studentDoc"
        let fileURL = documentUrl.URLByAppendingPathComponent(fileExtension)
        let document = Document(fileURL: fileURL)
        document.addEmptyPage()
        document.saveToURL(fileURL, forSaveOperation: .ForCreating) {
            (success) -> Void in
            document.savePresentedItemChangesWithCompletionHandler {
                (error) -> Void in
                DocumentSynchronizer.sharedInstance.document = document
            }
        }
        performSegueWithIdentifier("test", sender: nil)
    }

    //  MARK: - UIDocumenPicker


    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        let documentUrl = try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
        let fileExtension = String(NSDate().timeIntervalSinceReferenceDate) + "test.studentDoc"
        let fileURL = documentUrl.URLByAppendingPathComponent(fileExtension)
        let document = Document(fileURL: fileURL)
        document.addPDF(url)
        DocumentSynchronizer.sharedInstance.document = document
        performSegueWithIdentifier("test", sender: nil)
    }

}
