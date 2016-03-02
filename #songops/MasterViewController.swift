//
//  MasterViewController.swift
//  #songops
//
//  Created by Michael Smith on 7/11/15.
//  Copyright (c) 2015 Simple Things. All rights reserved.
//

import UIKit
import SwiftHTTP
import JSONJoy
import XCGLogger

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    let log = XCGLogger.defaultInstance()
    let dateFormatter = NSDateFormatter()

    @IBOutlet weak var detailDescriptionLabel: UILabel!

    var objects = [Queued]()
    var room = ""
    let roomKey = "room"
    var host = 0
    let hostKey = "host"
    let hosts = ["https://vbapi-mock.herokuapp.com", "http://vbsongs.com"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let defaults = NSUserDefaults.standardUserDefaults()
        room = defaults.stringForKey(roomKey)!
        host = defaults.integerForKey(hostKey)
        log.debug("loaded user settings: room=\(room), host=\(host)")

        refresh(self)

        self.navigationItem.leftBarButtonItem = self.editButtonItem()

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

    func apiUrl(cmd: String) -> String {
        return "\(hosts[host])/api/v1/\(cmd)"
    }

    func insertNewObject(sender: AnyObject) {
        // TODO: Implement song search, and adding songs to queue
        objects.append(Queued(JSONDecoder(["title": "Something", "artist": "Somebody"])))
        let indexPath = NSIndexPath(forRow: objects.count-1, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    func refresh(sender: AnyObject) {
        let cmd = apiUrl("queue")
        self.log.debug("getting \(cmd) for room \(room)")
        do {
            let opt = try HTTP.GET(cmd, parameters: ["room_code": room], requestSerializer: JSONParameterSerializer())
            opt.start {response in
                self.log.debug("\(response.description)")
                if let err = response.error {
                    self.log.warning(err.localizedDescription)
                    self.refreshControl?.endRefreshing()
                    return
                }
                if let queue = JSONDecoder(response.data)["queue"].array {
                    self.objects = queue.map({Queued($0)})
                }
                // Reset local objects and tableView
                // TODO: Look at http://stackoverflow.com/questions/805626/diff-algorithm or https://github.com/NSProgrammer/NSProgrammer/blob/master/code/Examples/TableViewChanges/TableViewChanges/NOBDTableViewOptimizationsNavigationController.m
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        } catch let error {
            self.log.warning("got an error creating the request: \(error)")
        }
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let object = objects[indexPath.row]
                let controller = segue.destinationViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        } else if segue.identifier == "showSettings" {
            self.log.debug("segue to settings: \(hosts[host]) - \(room)")
            let controller = segue.destinationViewController as! SettingsViewController
            controller.masterViewController = self
        } else if segue.identifier == "showSearch" {
            self.log.debug("segue to search")
            let controller = segue.destinationViewController as! SearchViewController
            controller.masterViewController = self
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
        let cell = tableView.dequeueReusableCellWithIdentifier("QueueCell", forIndexPath: indexPath)

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

            let cmd = apiUrl("queue")
            self.log.debug("deleting \(cmd) song \(indexPath.row) for room \(room)")
            let params: [String: AnyObject] = ["room_code": room, "from": indexPath.row]
            do {
                let opt = try HTTP.DELETE(cmd, parameters: params, requestSerializer: JSONParameterSerializer())
                opt.start {response in
                    self.log.debug("\(response.description)")
                    if let err = response.error {
                        self.log.warning(err.localizedDescription)
                    }
                }
            } catch let error {
                self.log.warning("got an error creating the request: \(error)")
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
            //insertNewObject(self)
        }
    }

    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        let object = objects.removeAtIndex(fromIndexPath.row)
        objects.insert(object, atIndex: toIndexPath.row)

        let cmd = apiUrl("queue/reorder")
        self.log.debug("posting \(cmd) from \(fromIndexPath.row) to \(toIndexPath.row) for room \(room)")
        let params: [String: AnyObject] = ["room_code": room, "from": fromIndexPath.row, "to": toIndexPath.row]
        do {
            let opt = try HTTP.POST(cmd, parameters: params, requestSerializer: JSONParameterSerializer())
            opt.start {response in
                self.log.debug("\(response.description)")
                if let err = response.error {
                    self.log.warning(err.localizedDescription)
                }
            }
        } catch let error {
            self.log.warning("got an error creating the request: \(error)")
        }
    }
}
