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
    
    @IBAction func doFitbitAuth(sender: UIButton) {
        
        let accessToken = FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")
        if accessToken == nil || accessToken!.characters.count == 0 {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FitbitLoginViewController") as! FitbitLoginViewController
            secondViewController.delegate = self
            secondViewController.methodStatus = "syncAll"
            self.navigationController?.pushViewController(secondViewController, animated: true)
        } else {
            self.syncAll()
        }
    }
    
    func syncAll() {
        healthManager?.recentSteps({steps, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let totalSteps = (steps[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int) {
                    let healthKitSteps = Int(totalSteps)
                    self.fitbitManager.getFitbitSteps({(result)-> Void in
                        if let fitbitSteps = result {
                            if(healthKitSteps == fitbitSteps) {
                                let alertController = UIAlertController(
                                    title: "Your data is synced.",
                                    message: "👍🏼",
                                    preferredStyle: UIAlertControllerStyle.Alert
                                )
                                
                                let confirmAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) in
                                    
                                }
                                
                                alertController.addAction(confirmAction)                                
                                self.presentViewController(alertController, animated: true, completion: nil)
                            }
                            else if(healthKitSteps < fitbitSteps){
                                let  stepsDifference = (fitbitSteps - healthKitSteps)
                                self.healthManager?.saveSteps(stepsDifference)
                            }else if(healthKitSteps > fitbitSteps){
                                let stepsDifference = (healthKitSteps - fitbitSteps)
                                self.fitbitManager.syncStepsWithFitbit(stepsDifference)
                            }
                        }
                        let alert = UIAlertController(title: "Congrats", message:"Your data sync is complete", preferredStyle: .Alert)
                        self.presentViewController(alert, animated: true){}
                    })
                } else {
                    let alert = UIAlertController(title: "Error", message:"Try syncing again.", preferredStyle: .Alert)
                    self.presentViewController(alert, animated: true){}
                }
            }
        })
    }
  

}
