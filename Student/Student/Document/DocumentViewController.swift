//
//  DocumentViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PagesOverviewTableViewCellDelegate, DocumentSynchronizerDelegate, UITextFieldDelegate {

    @IBOutlet weak var settingsWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagesOverviewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    
    private final let defaultSettingsWidth: CGFloat = 240
    private final let defaultPagesOverViewWidth: CGFloat = 180

    var isFullScreen = false
    
    weak var pagesOverviewController: PagesOverviewTableViewController?
    var isLoadingImage = false
    
    var document: Document? {
        get {
            return DocumentInstance.sharedInstance.document
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTitle()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerNotifications()
        DocumentInstance.sharedInstance.addDelegate(self)
        updateUndoRedoButtons()
        isLoadingImage = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.delegate = self
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if !isLoadingImage {
            titleTextField.delegate = nil
            DocumentInstance.sharedInstance.save()
            DocumentInstance.sharedInstance.removeDelegate(self)
            document?.closeWithCompletionHandler({
                (Bool) -> Void in
            })
            removeNotifications()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    func setUpTitle() {
        titleTextField.text = document?.name
        titleTextField.sizeToFit()
    }

    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateUndoRedoButtons"), name: NSUndoManagerWillUndoChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateUndoRedoButtons"), name: NSUndoManagerDidRedoChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("updateUndoRedoButtons"), name: NSUndoManagerCheckpointNotification, object: nil)
    }
    
    func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Actions

    @IBAction func handleAddPageButtonPressed(sender: AnyObject) {
        // TODO only reload last index, not full tableview
        document?.addEmptyPage()
    }

    @IBAction func handleDrawButtonPressed(sender: AnyObject) {
        PagesTableViewController.sharedInstance?.currentPageView()?.handleDrawButtonPressed()
    }

    @IBAction func handleImageButtonPressed(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.allowsEditing = false
        isLoadingImage = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func handleTextButtonPressed(sender: AnyObject) {
        if let textLayer = DocumentInstance.sharedInstance.currentPage?.addTextLayer("") {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView() {
                currentPageView.addTextLayer(textLayer)
                currentPageView.page = DocumentInstance.sharedInstance.currentPage
                currentPageView.setLayerSelected(currentPageView.subviews.count - 1)
            }
        }
    }

    @IBAction func handlePageInfoButtonPressed(sender: AnyObject) {
        PagesTableViewController.sharedInstance?.currentPageView()?.deselectSelectedSubview()
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
        DocumentExporter.exportAsImages(document!, sourceView: nil, barButtonItem: sender as? UIBarButtonItem)
    }

    @IBAction func handleFullscreenToggleButtonPressed(sender: UIBarButtonItem) {
        if isFullScreen {
            settingsWidthConstraint.constant = defaultSettingsWidth
            pagesOverviewWidthConstraint.constant = defaultPagesOverViewWidth
            isFullScreen = false
            sender.image = UIImage(named: "fullscreenOn")
        } else {
            settingsWidthConstraint.constant = 0
            pagesOverviewWidthConstraint.constant = 0
            isFullScreen = true
            sender.image = UIImage(named: "fullscreenOff")
        }

        UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.view.layoutIfNeeded()
            PagesTableViewController.sharedInstance?.layoutDidChange()
        }, completion: nil)

    }
    
    @IBAction func handleUndoButtonPressed(sender: AnyObject) {
        undoManager?.undo()
    }
    
    @IBAction func handleRedoButtonPressed(sender: AnyObject) {
        undoManager?.redo()
    }
    
    func updateUndoRedoButtons() {
        redoButton.enabled = undoManager?.canRedo ?? false
        undoButton.enabled = undoManager?.canUndo ?? false
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? PagesOverviewTableViewController {
            viewController.pagesOverViewDelegate = self
            pagesOverviewController = viewController
        } else if let viewController = segue.destinationViewController as? PagesTableViewController {
            PagesTableViewController.sharedInstance = viewController
        }
    }

    @IBAction func unwind(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }

    // MARK: - PagesOverViewDelegate

    func showPage(index: Int) {
        PagesTableViewController.sharedInstance?.showPage(index)
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }

    // MARK: - DocumentSynchronizerDelegate
    
    func didUpdateDocument() {
        titleTextField.text = document?.name ?? titleTextField.text
    }

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String:AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let imageLayer = DocumentInstance.sharedInstance.currentPage?.addImageLayer(image) {
                if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView() {
                    currentPageView.addImageLayer(imageLayer)
                    currentPageView.page = DocumentInstance.sharedInstance.currentPage
                    currentPageView.setLayerSelected(currentPageView.subviews.count - 1)
                }
            }
        }
        dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - UIKeyCommands



    // TODO add more commands
    // commant + T create Text
    override var keyCommands: [UIKeyCommand]? {
        var commands = [UIKeyCommand]()

        if let settingsViewController = SettingsViewController.sharedInstance {
            switch settingsViewController.currentSettingsType {
            case .Image:
                commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .Control, action: "handleRotateImageKeyPressed:", discoverabilityTitle: "Rotate Image Right"))
                commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .Control, action: "handleRotateImageKeyPressed:", discoverabilityTitle: "Rotate Image Left"))
                break
            default:
                break
            }
        }

        if let _ = PagesTableViewController.sharedInstance?.currentPageView()?.selectedSubView as? MovableView {
            commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .Command, action: "handleMoveMovableViewKeyPressed:", discoverabilityTitle: "Move Right"))
            commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .Command, action: "handleMoveMovableViewKeyPressed:", discoverabilityTitle: "Move Left"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: .Command, action: "handleMoveMovableViewKeyPressed:", discoverabilityTitle: "Move Up"))
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: .Command, action: "handleMoveMovableViewKeyPressed:", discoverabilityTitle: "Move Down"))
        } else {
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: .Command, action: "handleDownKeyPressed:", discoverabilityTitle: "Scroll Down"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: .Command, action: "handleUpKeyPressed:", discoverabilityTitle: "Scroll Up"))
        }

        return commands
    }

    func handleRotateImageKeyPressed(sender: UIKeyCommand) {
        if let imageSettingsViewController = SettingsViewController.sharedInstance?.currentChildViewController as? ImageSettingsViewController {
            imageSettingsViewController.rotateImage(sender.input == UIKeyInputRightArrow ? .Right : .Left)
        }
    }

    func handleDownKeyPressed(sender: UIKeyCommand) {
        PagesTableViewController.sharedInstance?.scroll(true)
    }

    func handleUpKeyPressed(sender: UIKeyCommand) {
        PagesTableViewController.sharedInstance?.scroll(false)
    }

    func handleMoveMovableViewKeyPressed(sender: UIKeyCommand) {
        guard let movableView = PagesTableViewController.sharedInstance?.currentPageView()?.selectedSubView as? MovableView else {
            return
        }
        let offSet = 10
        var translation = CGPointZero
        switch sender.input {
        case UIKeyInputRightArrow:
            translation = CGPoint(x: offSet, y: 0)
            break
        case UIKeyInputLeftArrow:
            translation = CGPoint(x: -offSet, y: 0)
            break
        case UIKeyInputDownArrow:
            translation = CGPoint(x: 0, y: offSet)
            break
        case UIKeyInputUpArrow:
            translation = CGPoint(x: 0, y: -offSet)
            break
        default:
            break
        }
        movableView.selectedTouchControl = .Center
        movableView.handlePanTranslation(translation)
        movableView.handlePanEnded()
    }

    // MARK - UITextfieldDelegate

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.borderStyle = .RoundedRect
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if let newName = textField.text {
            DocumentInstance.sharedInstance.renameDocument(newName, forceOverWrite: false, viewController: self, completion: {
                (success) -> Void in
                if !success {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.setUpTitle()
                    })
                }
            })
            textField.borderStyle = .None
        }
    }
}
