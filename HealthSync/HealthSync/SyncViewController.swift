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
        
        healthManager.recentSteps({stepMap, error in
            print("Recent Steps: \(stepMap[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE])")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func syncWithHealthKit(sender: AnyObject) {
        healthManager.recentSteps({stepMap, error in
            dispatch_async(dispatch_get_main_queue()) {
                let healthKitSteps = (stepMap[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int)!
                if(self.totalSteps == healthKitSteps) {
                        print("Data Already Synced");
                } else {
                    self.synStepsWithHealthKit(healthKitSteps)
                }
            }
        })
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
