//
//  SyncAllViewController.swift
//  HealthSync
//
//  Created by Girish Chaudhari on 11/22/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import UIKit

class SyncAllViewController: UIViewController {
    
    let fitbitManager = FitBitManager()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func doFitbitAuth(sender: UIButton) {
        
        fitbitManager.doFitBitOAuth()
/*
        if let accessToken = FitBitCredentials.sharedInstance.fitBitValueForKey("access_token") {
            if accessToken.characters.count == 0 {
                fitbitManager.doFitBitOAuth()
            } else {
                print("Already authenticated")
            }
        }
*/
    }
    
    @IBAction func getProfile(sender: UIButton) {
        
        fitbitManager.getProfileData({(result)-> Void in
          let test =   result as! FitBitUserProfile
            print(test.weight)
        })
        
        
    }
}
