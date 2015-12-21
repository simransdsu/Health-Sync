//
//  Constant.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 11/22/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import Foundation

class FitBitCredentials {
    
    static var instance: FitBitCredentials?
    
    class var sharedInstance: FitBitCredentials {
        if instance == nil {
            instance = FitBitCredentials()
            instance?.desynchronize()
        }
        
        return instance!
    }
    
    private var fitbit: Dictionary<String, String>?
    
    func setFitbitValue(value: String, withKey key: String) {
        fitbit![key] = value
        synchronize()
    }
    
    func fitBitValueForKey(key: String) -> String? {
        return fitbit![key]
    }
    
    
    func synchronize() {
        NSUserDefaults().setObject(fitbit, forKey: "Fitbit")
    }
    
    func desynchronize() {
        let fitBitCredentials = [
            "consumerKey": "b89c31136820a330acc344c3e8b1177b",
            "consumerSecret": "1e4938ee307d982b65afbd2df0a55d0b",
            "clientID":"229R6V"
        ]
        
        self.fitbit = NSUserDefaults().objectForKey("Fitbit") as? Dictionary<String, String>
        if self.fitbit == nil {
            self.fitbit = Dictionary<String, String>()
            for (key, value) in fitBitCredentials {
                self.setFitbitValue(value, withKey: key)
            }
        }
        
    }
    
}