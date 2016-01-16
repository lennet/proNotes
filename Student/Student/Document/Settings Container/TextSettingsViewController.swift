//
//  TextSettingsViewController.swift
//  Student
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

protocol TextSettingsDelegate {
    func removeText()

    func changeTextColor(color: UIColor)

    func changeBackgroundColor(color: UIColor)

    func changeAlignment(textAlignment: NSTextAlignment)

    func changeFont(font: UIFont)

    func disableAutoCorrect(disable: Bool)
}

class TextSettingsViewController: SettingsBaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    enum FontPickerRows: Int{
        case Families
        case Names
        case Sizes
        
        static let allValues = [Families, Names, Sizes]
    }
    
    @IBOutlet weak var fontPicker: UIPickerView!
    static var delegate: TextSettingsDelegate?

    var fontFamilies = [String]()
    var fontNames = [String]()
    // TODO fill possible Font Sizes
    var fontSizes = [10, 12, 14, 15, 16, 18, 22]
    var selectedRow = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        fontFamilies = UIFont.familyNames()
        fontNames = UIFont.fontNamesForFamilyName(fontFamilies[selectedRow])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleTextColorValueChanged(button: UIButton) {
        if let newColor = button.backgroundColor {
            TextSettingsViewController.delegate?.changeTextColor(newColor)
        }
    }

    @IBAction func handleBackgroundColorValueChanged(button: UIButton) {
        if let newColor = button.backgroundColor {
            TextSettingsViewController.delegate?.changeBackgroundColor(newColor)
        }
    }

    @IBAction func handleTextAlignmentValueChanged(control: UISegmentedControl) {
        if let textAlignment = NSTextAlignment(rawValue: control.selectedSegmentIndex) {
            TextSettingsViewController.delegate?.changeAlignment(textAlignment)
        }
    }

    @IBAction func handleAutoCorrectValueChanged(aSwitch: UISwitch) {
        TextSettingsViewController.delegate?.disableAutoCorrect(!aSwitch.on)
    }

    // MARK: - UIPickerViewDataSource

    // TODO use enums instead of hardcoded rows

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return FontPickerRows.allValues.count
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let fontPickerRow = FontPickerRows(rawValue: component) {
            switch fontPickerRow {
            case .Families:
                return fontFamilies.count
            case .Names:
                return fontNames.count
            case .Sizes:
                return fontSizes.count
            }
        }
        print("Not supported compontentnumber for Fontpicker: \(component)")
        return 0
    }

    func getTitle(row: Int, forComponent component: Int) -> String {
        if let fontPickerRow = FontPickerRows(rawValue: component) {
            switch fontPickerRow {
            case .Families:
                return fontFamilies[row]
            case .Names:
                return fontNames[row].stringByReplacingOccurrencesOfString(fontFamilies[selectedRow], withString: "")
            case .Sizes:
                return String(fontSizes[row])
            }
        }
        print("Not supported compontentnumber for Fontpicker: \(component)")
        return ""
    }

    func getFont(row: Int, forComponent component: Int) -> UIFont {
        let fontSize = UIFont.systemFontSize()
        if let fontPickerRow = FontPickerRows(rawValue: component) {
            switch fontPickerRow {
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
        print("Not supported compontentnumber for Fontpicker: \(component)")
        return UIFont.systemFontOfSize(fontSize)
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
        let width = pickerView.bounds.width
        switch component {
        case 0:
            return width / 2.5
        case 1:
            return width / 2.5
        case 2:
            return width / 5
        default:
            return 0
        }
    }

    // MARK: - UIPickerViewDelegate 

    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            if selectedRow != row {
                selectedRow = row
                fontNames = UIFont.fontNamesForFamilyName(fontFamilies[selectedRow])
                pickerView.reloadComponent(1)
            }
            break
        case 1:
            break
        case 2:
            break
        default:
            return
        }


    }
}
