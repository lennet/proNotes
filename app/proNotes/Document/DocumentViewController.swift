//
//  DocumentViewController.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController, PagesOverviewTableViewCellDelegate, UITextFieldDelegate, ImportDataViewControllerDelgate, SettingsViewControllerDelegate {

    @IBOutlet weak var settingsContainerRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagesOverViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var pageInfoButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var sketchButton: UIBarButtonItem!

    weak var pagesOverviewController: PagesOverviewTableViewController?
    var isFullScreen = false
    var isSketchMode = false {
        didSet {
            if isSketchMode {
                sketchButton.image = UIImage(named: "sketchIconActive")
            } else {
                sketchButton.image = UIImage(named: "sketchIcon")
            }
        }
    }
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
        updateUndoButton()
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
            DocumentInstance.sharedInstance.save(nil)
            document?.closeWithCompletionHandler({
                (Bool) -> Void in
            })
            removeNotifications()
            undoManager?.removeAllActions()
        }
        
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }

    func setUpTitle() {
        titleTextField.text = document?.name
        titleTextField.sizeToFit()
    }

    func registerNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentViewController.updateUndoButton), name: NSUndoManagerWillUndoChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DocumentViewController.updateUndoButton), name: NSUndoManagerCheckpointNotification, object: nil)
    }

    func removeNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Actions

    @IBAction func handleSketchButtonPressed(sender: UIBarButtonItem) {
        isSketchMode = !isSketchMode
        if isSketchMode {
            PagesTableViewController.sharedInstance?.currentPageView?.handleSketchButtonPressed()
        } else {
            PagesTableViewController.sharedInstance?.currentPageView?.deselectSelectedSubview()
        }
    }

    @IBAction func handlePageInfoButtonPressed(sender: AnyObject) {
        PagesTableViewController.sharedInstance?.currentPageView?.deselectSelectedSubview()
        SettingsViewController.sharedInstance?.currentSettingsType = .PageInfo
    }

    @IBAction func handleFullscreenToggleButtonPressed(sender: UIBarButtonItem) {
        if isFullScreen {
            settingsContainerRightConstraint.constant = -SettingsViewController.sharedInstance!.view.bounds.width
            pagesOverViewLeftConstraint.constant = -pagesOverviewController!.view.bounds.width
            isFullScreen = false
            sender.image = UIImage(named: "fullscreenOn")
        } else {
            settingsContainerRightConstraint.constant = 0
            pagesOverViewLeftConstraint.constant = 0
            isFullScreen = true
            sender.image = UIImage(named: "fullscreenOff")
        }

        UIView.animateWithDuration(standardAnimationDuration, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 5, options: .CurveEaseInOut, animations: {
            () -> Void in
            self.view.layoutIfNeeded()
            PagesTableViewController.sharedInstance?.layoutDidChange()
        }, completion: nil)

    }

    @IBAction func handleUndoButtonPressed(sender: AnyObject) {
        undoManager?.undo()
    }

    func updateUndoButton() {
        undoButton.enabled = undoManager?.canUndo ?? false
    }

    // MARK: - PagesOverViewDelegate

    func showPage(index: Int) {
        PagesTableViewController.sharedInstance?.showPage(index)
    }

    // MARK: - UIKeyCommands

    override var keyCommands: [UIKeyCommand]? {
        var commands = [UIKeyCommand]()

        if let settingsViewController = SettingsViewController.sharedInstance {
            switch settingsViewController.currentSettingsType {
            case .Image:
                commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .Control, action: #selector(DocumentViewController.handleRotateImageKeyPressed(_:)), discoverabilityTitle: "Rotate Image Right"))
                commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .Control, action: #selector(DocumentViewController.handleRotateImageKeyPressed(_:)), discoverabilityTitle: "Rotate Image Left"))
                break
            default:
                break
            }
        }

        if let _ = PagesTableViewController.sharedInstance?.currentPageView?.selectedSubView as? MovableView {
            commands.append(UIKeyCommand(input: UIKeyInputRightArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Right"))
            commands.append(UIKeyCommand(input: UIKeyInputLeftArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Left"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Up"))
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: .Command, action: #selector(DocumentViewController.handleMoveMovableViewKeyPressed(_:)), discoverabilityTitle: "Move Down"))
        } else {
            commands.append(UIKeyCommand(input: UIKeyInputDownArrow, modifierFlags: [], action: #selector(DocumentViewController.handleDownKeyPressed(_:)), discoverabilityTitle: "Scroll Down"))
            commands.append(UIKeyCommand(input: UIKeyInputUpArrow, modifierFlags: [], action: #selector(DocumentViewController.handleUpKeyPressed(_:)), discoverabilityTitle: "Scroll Up"))
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
        guard let movableView = PagesTableViewController.sharedInstance?.currentPageView?.selectedSubView as? MovableView else {
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

    // MARK: - UITextfieldDelegate

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

    // MARK: - ImportDataViewControllerDelegate
    
    weak var importDataNavigationController: UINavigationController?

    func addEmptyPage() {
        document?.addEmptyPage()
        dismiss()
    }

    func addTextField() {
        if let textLayer = DocumentInstance.sharedInstance.currentPage?.addTextLayer("") {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView {
                currentPageView.addTextLayer(textLayer)
                currentPageView.page = DocumentInstance.sharedInstance.currentPage
                currentPageView.setLayerSelected(currentPageView.subviews.count - 1)
                if let pageIndex = currentPageView.page?.index {
                    DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
                }
            }
        }
        dismiss()
    }

    func addPDF(url: NSURL) {
        document?.addPDF(url)
        dismiss()
    }

    func addImage(image: UIImage) {
        if let imageLayer = DocumentInstance.sharedInstance.currentPage?.addImageLayer(image) {
            if let currentPageView = PagesTableViewController.sharedInstance?.currentPageView {
                currentPageView.addImageLayer(imageLayer)
                currentPageView.page = DocumentInstance.sharedInstance.currentPage
                currentPageView.setLayerSelected(currentPageView.subviews.count - 1)
                if let pageIndex = currentPageView.page?.index {
                    DocumentInstance.sharedInstance.didUpdatePage(pageIndex)
                }
            }
        }
        dismiss()
    }
    
    func addSketchLayer() {
        PagesTableViewController.sharedInstance?.currentPageView?.addSketchLayer()
        dismiss()
    }

    func dismiss() {
        importDataNavigationController?.dismissViewControllerAnimated(true, completion: nil)
        importDataNavigationController = nil
    }
    
    // MARK: - SettingsViewControllerDelegate
    
    func didChangeSettingsType(newType: SettingsViewControllerType) {
        pageInfoButton.setHidden(newType != .PageInfo)
        isSketchMode = newType == .Sketch
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let viewController = segue.destinationViewController as? PagesOverviewTableViewController {
            viewController.pagesOverViewDelegate = self
            pagesOverviewController = viewController
        } else if let viewController = segue.destinationViewController as? PagesTableViewController {
            PagesTableViewController.sharedInstance = viewController
        } else if let viewController = segue.destinationViewController as? SettingsViewController {
            viewController.delegate = self
        } else if let navigationController = segue.destinationViewController as? UINavigationController {
            if let viewController = navigationController.visibleViewController as? ImportDataViewController {
                viewController.delegate = self
            }
            importDataNavigationController = navigationController
        }
    }
    
    @IBAction func unwind(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
}
