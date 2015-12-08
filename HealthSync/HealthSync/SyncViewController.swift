//
//  SyncViewController.swift
//  HealthSync
//
//  Created by Simran Preet S Narang on 11/7/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import UIKit

class SyncViewController: UIViewController {
    var totalSteps: Int = 0
    let healthManager = HealthManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Steps Walked: \t\t\(self.totalSteps)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func syncWithHealthKit(sender: AnyObject) {
         
        
        
    }

    @IBAction func syncWithFitbit(sender: AnyObject) {
        
        
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
        let fitbitManager = FitBitManager()
        fitbitManager.syncStepsWithFitbit(totalSteps)
        
//        let fitbitManager = FitBitManager()
//        healthManager.recentSteps({steps, error in
//            dispatch_async(dispatch_get_main_queue()) {
//                if let totalSteps = (steps[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int) {
//                    let healthKitSteps = Int(totalSteps)
//                    fitbitManager.getFitbitSteps({(result)-> Void in
//                        if let fitbitSteps = result {
//                            if(healthKitSteps < fitbitSteps){
//                                let  stepsDifference = (fitbitSteps - healthKitSteps)
//                                self.healthManager.saveSteps(stepsDifference)
//                            }else if(healthKitSteps > fitbitSteps){
//                                let stepsDifference = (healthKitSteps - fitbitSteps)
//                                fitbitManager.syncStepsWithFitbit(stepsDifference)
//                            }
//                        }
//                    })
//                } else {
//                    let alert = UIAlertController(title: "Health Kit Disabled", message:"Please enable Health", preferredStyle: .Alert)
//                    self.presentViewController(alert, animated: true){}
//                }
//            }
//        })
    }
    
    
    
    func synStepsWithHealthKit(healthKitSteps: Int) {
        let stepsDifference = self.totalSteps - healthKitSteps;
        if(stepsDifference > 0) {
            self.healthManager.saveSteps(stepsDifference)
        }
        print("Steps Difference is: \(stepsDifference)")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
