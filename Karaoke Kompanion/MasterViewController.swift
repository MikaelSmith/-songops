//
//  MasterViewController.swift
//  Karaoke Kompanion
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 Simple Things. All rights reserved.
//

import UIKit
import SwiftHTTP
import XCGLogger

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Song]()
    let log = XCGLogger.defaultInstance()

    // TODO: Allow setting host and room in the app.
    // https://www.airpair.com/swift/building-swift-app-tutorial-3
    let room = "ABCD"
    // let host = "https://voiceboxpdx.com"
    let host = "https://vbapi-mock.herokuapp.com"

    let dateFormatter = NSDateFormatter()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        refresh(self)

        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        // Disable adding new items
        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //self.navigationItem.rightBarButtonItem = addButton

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }

        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        // TODO: http://b2cloud.com.au/how-to-guides/reordering-a-uitableviewcell-from-any-touch-point/
        // https://github.com/adamraudonis/UITableViewCell-Swipe-for-Options
        //self.setEditing(true, animated: true)
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        // TODO: Implement song search, and adding songs to queue
        objects.append(Song(json: ["title": "Something", "artist": "Somebody"]))
        let indexPath = NSIndexPath(forRow: objects.count-1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    func refresh(sender: AnyObject) {
        let request = HTTPTask()
        request.responseSerializer = JSONResponseSerializer()
        request.GET("\(host)/api/v1/queue", parameters: ["room_code": room], completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                self.log.warning(err.localizedDescription)
                return
            }
            if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                self.log.debug("\(dict)")
                let queue = dict["queue"] as! [Dictionary<String,AnyObject>]

                // Reset local objects and tableView
                // TODO: Look at http://stackoverflow.com/questions/805626/diff-algorithm or https://github.com/NSProgrammer/NSProgrammer/blob/master/code/Examples/TableViewChanges/TableViewChanges/NOBDTableViewOptimizationsNavigationController.m
                self.objects = queue.map({Song(json: $0)})
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        })
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object.title
        cell.detailTextLabel!.text = object.artist
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            let request = HTTPTask()
            request.responseSerializer = JSONResponseSerializer()
            request.DELETE("\(host)/api/v1/queue", parameters: ["room_code": room, "from": indexPath.row], completionHandler: {(response: HTTPResponse) in
                if let err = response.error {
                    self.log.warning(err.localizedDescription)
                    return
                }
                if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                    self.log.debug("\(dict)")
                }
            })
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
            //insertNewObject(self)
        }
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let object = objects.removeAtIndex(fromIndexPath.row)
        objects.insert(object, atIndex: toIndexPath.row)

        let request = HTTPTask()
        request.responseSerializer = JSONResponseSerializer()
        request.POST("\(host)/api/v1/queue/reorder", parameters: ["room_code": room, "from": fromIndexPath.row, "to": toIndexPath.row], completionHandler: {(response: HTTPResponse) in
            if let err = response.error {
                self.log.warning(err.localizedDescription)
                return
            }
            if let dict = response.responseObject as? Dictionary<String,AnyObject> {
                self.log.debug("\(dict)")
            }
        })
    }
}
