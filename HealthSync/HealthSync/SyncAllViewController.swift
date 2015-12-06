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

        let accessToken = FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")
        if accessToken == nil || accessToken!.characters.count == 0 {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FitbitLoginViewController") as! FitbitLoginViewController
            secondViewController.delegate = self
            secondViewController.methodStatus = "getProfileData"
            self.navigationController?.pushViewController(secondViewController, animated: true)
        } else {
            self.getProfileData()
        }
        
    }
    
    @IBAction func getProfile(sender: UIButton) {
        
    }
    
    func getProfileData() {
        fitbitManager.getProfileData({(result)-> Void in
            let test =   result as! FitBitUserProfile
            print("========================== Weight is: \(test.weight)")
        })
    }
}
