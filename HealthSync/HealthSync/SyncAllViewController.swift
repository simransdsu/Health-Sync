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
        
    }
    
    @IBAction func getProfile(sender: UIButton) {
        
        fitbitManager.getProfileData()
        
        
    }
}
