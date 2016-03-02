//
//  SettingsViewController.swift
//  #songops
//
//  Created by Michael Smith on 7/15/15.
//  Copyright © 2015 Simple Things. All rights reserved.
//

import UIKit
import XCGLogger

class SettingsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var websiteSelector: UIPickerView!
    @IBOutlet weak var roomCodeField: UITextField!

    let log = XCGLogger.defaultInstance()

    var masterViewController: MasterViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.roomCodeField.text = self.masterViewController?.room
        self.websiteSelector.selectRow((self.masterViewController?.host)!, inComponent: 0, animated: false)
    }

    override func viewWillDisappear(animated: Bool) {
        let host = self.websiteSelector.selectedRowInComponent(0)
        let room = self.roomCodeField.text!
        self.log.debug("settings disappearing: \(host) - \(room)")
        if (self.masterViewController?.host != host || self.masterViewController?.room != room) {
            self.masterViewController?.host = host
            self.masterViewController?.room = room
            self.masterViewController?.refresh(self)

            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(room, forKey: (self.masterViewController?.roomKey)!)
            defaults.setInteger(host, forKey: (self.masterViewController?.hostKey)!)
            log.debug("saved user settings: room=\(room), host=\(host)")
        }
    }

    // MARK: - Picker View
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (self.masterViewController?.hosts.count)!
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel()
        label.text = self.masterViewController?.hosts[row]
        label.textAlignment = .Left
        return label
    }
}