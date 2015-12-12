//
//  SyncLogger.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 12/11/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import Foundation

class SyncLogger {
    
    
    class var sharedInstance: SyncLogger {
        
        struct Singleton {
            static let instance = SyncLogger()
        }
        
        return Singleton.instance
    }
    
    
    func saveSyncLogs (logs:AnyObject?){
        guard let synclogs = logs else{
            return
        }
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(synclogs as! NSArray)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: "synclogs")
        defaults.synchronize()
    }
    
    func getSyncLogs ()->AnyObject?{
        guard let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("synclogs") as? NSData else {
            return nil
        }
        return (NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [SyncLog])!
    }
    
    func storeSyncLogs(syncSource:String,steps:Int){
        let syncType:String = getSyncType(syncSource)
        let syncDate = getSyncDate()
        
        let syncLog = SyncLog(syncType: syncType, syncDate: syncDate, stepSynced: steps)
        
        guard let synclogs = getSyncLogs() else{
            var synclogs = [SyncLog]()
            synclogs.append(syncLog)
            saveSyncLogs(synclogs)
            return
        }
        
        var lastSavedSyncLogs = synclogs as! [SyncLog]
        
        lastSavedSyncLogs.append(syncLog)
        saveSyncLogs(lastSavedSyncLogs)
    }
    
    func  getSyncType(syncSource:String)-> String {
        var syncType = ""
        
        if(syncSource == "HSTOF"){
            syncType = "HealthSync --> Fitbit"
        }else if(syncSource == "HTOF"){
            syncType = "HealthKit --> Fitbit"
        }else{
            syncType = "Fitbit --> HealthKit"
        }
        
        return syncType
    }
    
    func clearSyncLogs(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey("synclogs")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
}