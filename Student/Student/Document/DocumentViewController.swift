//
//  DocumentViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PagesOverviewTableViewCellDelegate, DocumentSynchronizerDelegate {

    @IBOutlet weak var settingsWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagesOverviewWidthConstraint: NSLayoutConstraint!

    final let defaultSettingsWidth: CGFloat = 240
    final let defaultPagesOverViewWidth: CGFloat = 180

    var isFullScreen = false

    var pagesOverviewController: PagesOverviewTableViewController?
    var document: Document? = DocumentSynchronizer.sharedInstance.document


    override func viewDidLoad() {
        super.viewDidLoad()
        DocumentSynchronizer.sharedInstance.addDelegate(self)
        document = DocumentSynchronizer.sharedInstance.document
        PagesTableViewController.sharedInstance?.document = document
    }

    deinit {
        DocumentSynchronizer.sharedInstance.removeDelegate(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    // MARK: - Actions

    @IBAction func handleAddPageButtonPressed(sender: AnyObject) {
        document?.addEmptyPage()
        DocumentSynchronizer.sharedInstance.document = document
    }

    @IBAction func handleDrawButtonPressed(sender: AnyObject) {
        PagesTableViewController.sharedInstance?.currentPageView()?.handleDrawButtonPressed()
    }

    @IBAction func handleImageButtonPressed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.allowsEditing = false
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func handleTextButtonPressed(sender: AnyObject) {
        if let textLayer = DocumentSynchronizer.sharedInstance.currentPage?.addTextLayer("") {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView() {
                currentPageView.addTextLayer(textLayer)
                currentPageView.page = DocumentSynchronizer.sharedInstance.currentPage
                currentPageView.setLayerSelected(currentPageView.subviews.count - 1)
            }
        }
    }

    @IBAction func handlePlotButtonPressed(sender: AnyObject) {
        document?.addPlotToPage(0)
    }

    @IBAction func handlePageInfoButtonPressed(sender: AnyObject) {
        PagesTableViewController.sharedInstance?.currentPageView()?.deselectSelectedSubview()
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .PageInfo
    }

    @IBAction func handleFullscreenToggleButtonPressed(sender: AnyObject) {
        // TODO Change BarButtonIcon
        if isFullScreen {
            settingsWidthConstraint.constant = defaultSettingsWidth
            pagesOverviewWidthConstraint.constant = defaultPagesOverViewWidth
            isFullScreen = false
        } else {
            settingsWidthConstraint.constant = 0
            pagesOverviewWidthConstraint.constant = 0
            isFullScreen = true
        }

        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.view.layoutIfNeeded()
        }, completion: nil)

    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? PagesOverviewTableViewController {
            viewController.pagesOverViewDelegate = self
            pagesOverviewController = viewController
        } else if let viewController = segue.destinationViewController as? PagesTableViewController {
            PagesTableViewController.sharedInstance = viewController
        }
    }

    // MARK: - PagesOverViewDelegate

    func showPage(index: Int) {
        PagesTableViewController.sharedInstance?.showPage(index)
        DocumentSynchronizer.sharedInstance.settingsViewController?.setUpChildViewController(.PageInfo)
    }

    // MARK: - DocumentSynchronizerDelegate
    func updateDocument(document: Document, forceReload: Bool) {
        self.document = document
    }

    func currentPageDidChange(page: DocumentPage) {
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            document?.addImageToPage(image, pageIndex: 0)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UIKeyCommands

    // TODO add more commands
    override var keyCommands: [UIKeyCommand]? {
        return [
                UIKeyCommand(input: "+", modifierFlags: .Command, action: "handleAddPageButtonPressed:", discoverabilityTitle: "Add Page"),
        ]
    }

    func selectTab(sender: UIKeyCommand) {
        let selectedTab = sender.input
        print(selectedTab)
    }

}
