//
//  DetailViewController.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 Simple Things. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    var detailItem: Song? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // TODO: Add all info to detail view
        // Update the user interface for the detail item.
        if let detail: Song = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = "\(detail.title) - \(detail.artist)"
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

