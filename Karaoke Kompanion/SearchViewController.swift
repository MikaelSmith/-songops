//
//  SearchViewController.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 8/16/15.
//  Copyright © 2015 Simple Things. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy
import XCGLogger

class SearchViewController: UITableViewController, UISearchBarDelegate {

    let log = XCGLogger.defaultInstance()

    var masterViewController: MasterViewController? = nil

    var objects = [Song]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()

        let cmd = self.masterViewController!.apiUrl("songs/search")
        self.log.debug("getting \(cmd) for \(searchBar.text!)")
        do {
            let opt = try HTTP.GET(cmd, parameters: ["query": searchBar.text!], requestSerializer: JSONParameterSerializer())
            opt.start {response in
                self.log.debug("\(response.description)")
                if let err = response.error {
                    self.log.warning(err.localizedDescription)
                    return
                }
                if let queue = JSONDecoder(response.data)["songs"].array {
                    self.objects = queue.map({Song($0)})
                }
                self.log.debug("found \(self.objects.count) songs")
                self.tableView.reloadData()
            }
        } catch let error {
            self.log.warning("got an error creating the request: \(error)")
        }
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
        self.log.debug("selected \(object.title) \(object.artist) with id \(object.id)")

        let cmd = self.masterViewController!.apiUrl("queue")
        self.log.debug("posting \(cmd)?room_code=\(self.masterViewController!.room)&song_id=\(object.id)")
        do {
            let opt = try HTTP.POST(cmd, parameters: ["room_code": self.masterViewController!.room, "song_id": String(object.id!)], requestSerializer: JSONParameterSerializer())
            opt.start {response in
                self.log.debug("\(response.description)")
                if let err = response.error {
                    self.log.warning(err.localizedDescription)
                    return
                }
                self.masterViewController!.refresh(self)
            }
        } catch let error {
            self.log.warning("got an error creating the request: \(error)")
        }

        self.navigationController!.popViewControllerAnimated(true)
    }
}