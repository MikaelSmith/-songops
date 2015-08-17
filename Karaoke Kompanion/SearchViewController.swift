//
//  SearchViewController.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 8/16/15.
//  Copyright © 2015 Simple Things. All rights reserved.
//

import UIKit
import XCGLogger

class SearchViewController: UITableViewController, UISearchBarDelegate {
    
    let log = XCGLogger.defaultInstance()

    var masterViewController: MasterViewController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillDisappear(animated: Bool) {
    }
}