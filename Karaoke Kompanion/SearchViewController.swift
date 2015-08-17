//
//  SearchViewController.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 8/16/15.
//  Copyright © 2015 Simple Things. All rights reserved.
//

import UIKit
import SwiftHTTP
import XCGLogger

class SearchViewController: UITableViewController, UISearchBarDelegate {

    let log = XCGLogger.defaultInstance()

    var masterViewController: MasterViewController? = nil

    var objects = [CatalogItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        let request = HTTPTask()
        request.responseSerializer = JSONResponseSerializer()
        let cmd = self.masterViewController!.apiUrl("songs/search")
        self.log.debug("getting \(cmd) for \(searchBar.text!)")
        request.GET(cmd, parameters: ["query": searchBar.text!], completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                self.log.warning(err.localizedDescription)
                self.log.debug("\(response.responseObject)")
            } else if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                self.log.debug("\(dict)")
                let queue = dict["songs"] as! [Dictionary<String,AnyObject>]

                self.objects = queue.map({CatalogItem(json: $0)})
                self.log.debug("found \(self.objects.count) songs")
                self.tableView.reloadData()
            }
        })
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        self.log.debug("display cell \(indexPath.row): \(object.title) \(object.artist)")
        cell.textLabel!.text = object.title
        cell.detailTextLabel!.text = object.artist
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let object = objects[indexPath.row]
        self.log.debug("selected \(object.title) \(object.artist)")
    }
}