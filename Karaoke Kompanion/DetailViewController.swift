//
//  DetailViewController.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 Simple Things. All rights reserved.
//

import UIKit
import XCGLogger

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    let log = XCGLogger.defaultInstance()


    var detailItem: Queued? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // TODO: Add all info to detail view
        // Update the user interface for the detail item.
        if let detail: Queued = self.detailItem {
            if let label = self.detailDescriptionLabel {
                var displayText = "title: \(detail.title)\nartist: \(detail.artist)"
                if let play_id = detail.play_id {
                    displayText += "\nplay_id: \(play_id)"
                }
                if let position = detail.position {
                    displayText += "\nposition: \(position)"
                }
                if let duration = detail.duration {
                    displayText += "\nduration: \(duration)"
                }
                if let song_id = detail.song_id {
                    displayText += "\nsong_id: \(song_id)"
                }
                if let paused = detail.paused {
                    displayText += "\npaused: \(paused)"
                }
                label.text = displayText
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

