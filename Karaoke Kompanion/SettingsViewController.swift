//
//  SettingsViewController.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 7/15/15.
//  Copyright © 2015 Simple Things. All rights reserved.
//

import UIKit
import XCGLogger

class SettingsViewController: UITableViewController {

    let log = XCGLogger.defaultInstance()

    // TODO: Allow setting host and room in the app.
    // https://www.airpair.com/swift/building-swift-app-tutorial-3
    var room = "ABCD"
    // let host = "https://voiceboxpdx.com"
    var host = "https://vbapi-mock.herokuapp.com"

}