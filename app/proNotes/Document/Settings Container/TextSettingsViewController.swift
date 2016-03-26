//
//  TextSettingsViewController.swift
//  proNotes
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol TextSettingsDelegate: class {
    func removeText()

    func changeTextColor(color: UIColor)

    func changeBackgroundColor(color: UIColor)

    func changeAlignment(textAlignment: NSTextAlignment)

    func changeFont(font: UIFont)
    
    func getTextLayer() -> TextLayer?
}

// TODO finish styling

class TextSettingsViewController: SettingsBaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    private enum ColorPickerIdentifier: String {
        case BackgroundColor = "BackgroundColorIdentifier"
        case TextColor = "TextColorIdentifier"
    }
    
    private enum FontPickerComponent: Int {
        case Families
        case Names
        case Sizes

        static let allValues = [Families, Names, Sizes]
    }

    @IBOutlet weak var justifiedAlignmentButton: UIButton!
    @IBOutlet weak var rightAlignmentButton: UIButton!
    @IBOutlet weak var centerAlignmentButton: UIButton!
    @IBOutlet weak var leftAlignmentButton: UIButton!
    
    var alignmentButtons: [UIButton] {
        get {
            return [leftAlignmentButton, centerAlignmentButton, rightAlignmentButton, justifiedAlignmentButton]
        }
    }
    
    @IBOutlet weak var fontPicker: UIPickerView!
    static weak var delegate: TextSettingsDelegate?

    var fontFamilies = [String]()
    var fontNames = [String]()
    
    // TODO fill possible Font Sizes
    let fontSizes = [10, 12, 14, 15, 16, 18, 22]
    var selectedRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        fontFamilies = UIFont.familyNames()
        fontNames = UIFont.fontNamesForFamilyName(fontFamilies[selectedRow])
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        guard let textLayer = TextSettingsViewController.delegate?.getTextLayer() else {
            return
        }
        for button in alignmentButtons where button.tag == textLayer.alignment.rawValue {
            button.selected = true
        }
    }

    @IBAction func handleTextAlignmentValueChanged(control: UISegmentedControl) {
        if let textAlignment = NSTextAlignment(rawValue: control.selectedSegmentIndex) {
            TextSettingsViewController.delegate?.changeAlignment(textAlignment)
        }
    }

    // MARK: - UIPickerViewDataSource

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return FontPickerComponent.allValues.count
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard  let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return 0
        }
        switch fontPickerComponent {
        case .Families:
            return fontFamilies.count
        case .Names:
            return fontNames.count
        case .Sizes:
            return fontSizes.count
        }
    }

    func getTitle(row: Int, forComponent component: Int) -> String {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return ""
        }
    
        switch fontPickerComponent {
        case .Families:
            return fontFamilies[row]
        case .Names:
            return fontNames[row].stringByReplacingOccurrencesOfString(fontFamilies[selectedRow], withString: "")
        case .Sizes:
            return String(fontSizes[row])
        }
    }

    func getFont(row: Int, forComponent component: Int, fontSize: CGFloat = UIFont.systemFontSize()) -> UIFont {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return UIFont.systemFontOfSize(fontSize)
        }
        
        switch fontPickerComponent {
        case .Families:
            let fontName = fontFamilies[row]
            return UIFont(name: fontName, size: fontSize)!
        case .Names:
            let fontName = fontNames[row]
            return UIFont(name: fontName, size: fontSize)!
        default:
            return UIFont.systemFontOfSize(fontSize)
        }
    }

    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel;

        if (pickerLabel == nil) {
            pickerLabel = UILabel()

            pickerLabel?.font = getFont(row, forComponent: component)
            pickerLabel?.textAlignment = NSTextAlignment.Center
        }

        pickerLabel?.text = getTitle(row, forComponent: component)

        return pickerLabel!;
    }

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return 0
        }
        let width = pickerView.bounds.width
        switch fontPickerComponent {
        case .Families:
            return width / 2.5
        case .Names:
            return width / 2.5
        case .Sizes:
            return width / 5
        }
    }
    
    // MARK: - Actions
    
    @IBAction func handleAlignmentButtonPressed(sender: UIButton) {
        for button in alignmentButtons where button != sender && button.selected {
            button.selected = false
        }
        
        sender.selected = true
        guard let textAlignment = NSTextAlignment(rawValue: sender.tag) else {
            return
        }
        TextSettingsViewController.delegate?.changeAlignment(textAlignment)
    }

    // MARK: - UIPickerViewDelegate 

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let fontPickerComponent = FontPickerComponent(rawValue: component) else {
            print("Not supported compontentnumber for Fontpicker: \(component)")
            return
        }

        switch fontPickerComponent {
        case .Families:
            if selectedRow != row {
                selectedRow = row
                fontNames = UIFont.fontNamesForFamilyName(fontFamilies[selectedRow])
                pickerView.reloadComponent(FontPickerComponent.Names.rawValue)
            }
        default:
            break
        }
        let familyRow = pickerView.selectedRowInComponent(FontPickerComponent.Names.rawValue)
        let fontSize = CGFloat(fontSizes[pickerView.selectedRowInComponent(FontPickerComponent.Sizes.rawValue)])
        let selectedFont = getFont(familyRow, forComponent: FontPickerComponent.Names.rawValue, fontSize: fontSize)
        TextSettingsViewController.delegate?.changeFont(selectedFont)
    }
    
    // MARK: - ColorPickerDelegate
    
    override func didSelectColor(colorPicker: ColorPickerViewController, color: UIColor) {
        guard let colorPickerIdentifier = ColorPickerIdentifier(rawValue: colorPicker.identifier ?? "") else {
            return
        }
        switch colorPickerIdentifier {
        case .BackgroundColor:
            TextSettingsViewController.delegate?.changeBackgroundColor(color)
            break
        case .TextColor:
            TextSettingsViewController.delegate?.changeTextColor(color)
            break
        }
    }
    
}
