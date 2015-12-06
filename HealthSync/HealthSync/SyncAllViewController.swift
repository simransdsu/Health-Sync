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
    var healthManager: HealthManager? =  HealthManager()
    
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
    
    @IBAction func syncAll(sender: UIButton) {
        
        //let healthKitSteps = getStepsFromHealthKit()
        let healthKitSteps = 15000
        var fitbitSteps = 0
        
        fitbitManager.getFitbitSteps({(result)-> Void in
            fitbitSteps = result
            if(healthKitSteps < fitbitSteps){
                let  stepsDifference = (fitbitSteps - healthKitSteps)
                self.healthManager?.saveSteps(stepsDifference)
            }else{
                let stepsDifference = (healthKitSteps - fitbitSteps)
                self.fitbitManager.syncStepsWithFitbit(stepsDifference)
            }
        })
    }
    
    func getStepsFromHealthKit()->Int{
        var stepsFromHealthKit = 0
        healthManager?.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                self.healthManager?.recentSteps({steps, error in
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if let totalSteps = (steps[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int) {
                            stepsFromHealthKit = Int(totalSteps)
                        } else {
                            stepsFromHealthKit = 0
                        }
                    }
                })
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
        return stepsFromHealthKit
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
