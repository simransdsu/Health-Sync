//
//  SyncLog.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 12/10/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import Foundation

class SyncLog:NSObject,NSCoding {
    
    let syncType:String
    let syncDate:String
    let stepSynced:Int
    
    init(syncType:String,syncDate:String,stepSynced:Int){
        self.syncType = syncType
        self.syncDate = syncDate
        self.stepSynced = stepSynced
    }
    
    required init(coder aDecoder: NSCoder) {
        
        self.syncType = aDecoder.decodeObjectForKey("syncType") as! String
        self.syncDate = aDecoder.decodeObjectForKey("syncDate") as! String
        self.stepSynced = aDecoder.decodeObjectForKey("stepSynced") as! Int
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(syncType, forKey: "syncType")
        aCoder.encodeObject(syncDate, forKey: "syncDate")
        aCoder.encodeObject(stepSynced, forKey: "stepSynced")
    }
    
}