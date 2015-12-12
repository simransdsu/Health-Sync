//
//  SyncLogsViewController.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 12/10/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import UIKit

class SyncLogsViewController: UITableViewController {
    
    var synclogs = [SyncLog]()
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let CLEAR_BUTTON_HEIGHT:CGFloat = 50.0
    
    let clearLogButton   = UIButton(type: UIButtonType.Custom) as UIButton
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sync Logs"
    }
    
    override func viewWillAppear(animated: Bool) {
        loadAllSyncLogs()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.synclogs.count
    }
    
    private struct Storyboard{
        static let cellReuseIdentifier = "SyncLogs"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.cellReuseIdentifier, forIndexPath:indexPath)
        let log = synclogs[indexPath.row]
        
        cell.textLabel?.text  = log.syncType
        cell.detailTextLabel?.text = log.syncDate + "   " + String(log.stepSynced) + "  Steps Synced"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CLEAR_BUTTON_HEIGHT
    }
    
    
    func clearSyncLogs(sender: UIButton!) {
        let logger = SyncLogger.sharedInstance
        logger.clearSyncLogs()
        synclogs = [SyncLog]()
        showAlertView("Sync Logs", message: "Sync logs cleared.", view: self)
        tableView.reloadData()
        clearLogButton.hidden = true
        
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return clearLogButton
    }
    
    func createClearLogButton(){
        
        clearLogButton.frame = CGRectMake(50.0, 50.0, 70.0, 50.0)
        clearLogButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        clearLogButton.setTitle("Clear Logs", forState: UIControlState.Normal)
        clearLogButton.addTarget(self, action: "clearSyncLogs:", forControlEvents: UIControlEvents.TouchUpInside)
        
        clearLogButton.layer.borderWidth = 0.5
        clearLogButton.layer.cornerRadius = 5
        
        let themeColor = UIColor(red: 96/256, green: 191/256, blue: 186/256, alpha: 1)
        clearLogButton.backgroundColor = themeColor
        
        tableView.tableFooterView = clearLogButton
    }
    
    
    func loadAllSyncLogs(){
        
        let logger = SyncLogger.sharedInstance
        guard let logs = logger.getSyncLogs() else{
            showAlertView("Sync Logs", message: "No sync logs found !", view: self)
            return
        }
        clearLogButton.hidden = false
        createClearLogButton()
        
        synclogs = logs as! [SyncLog]
        synclogs = synclogs.reverse()
        
        tableView.reloadData()
    }
    
}
