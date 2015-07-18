//
//  SettingsViewController.swift
//  Karaoke Kompanion
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

    let hosts = ["https://vbapi-mock.herokuapp.com", "http://vbsongs.com"]
    var masterViewController: MasterViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.roomCodeField.text = self.masterViewController?.room
        for (index, value) in self.hosts.enumerate() {
            if (value == self.masterViewController?.host) {
                self.websiteSelector.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }

    override func viewWillDisappear(animated: Bool) {
        let host = hosts[self.websiteSelector.selectedRowInComponent(0)]
        let room = self.roomCodeField.text
        self.log.debug("settings disappearing: \(host) - \(room)")
        if (self.masterViewController?.host != host || self.masterViewController?.room != room!) {
            self.masterViewController?.host = host
            self.masterViewController?.room = room!
            self.masterViewController?.refresh(self)
        }
    }

    // MARK: - Picker View
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hosts.count
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let label = UILabel()
        label.text = hosts[row]
        label.textAlignment = .Left
        return label
    }
}