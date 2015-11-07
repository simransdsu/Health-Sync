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
        print("Steps: \(totalSteps)");
        healthManager.recentSteps({steps, error in
            print(steps)
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func syncWithHealthKit(sender: AnyObject) {
        healthManager.recentSteps({stepMap, error in
            dispatch_async(dispatch_get_main_queue()) {
                let healthKitSteps = (stepMap[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int)!
                if(self.totalSteps == healthKitSteps) {
                    print("Data Already Synced");
                } else {
                    let stepsDifference = self.totalSteps - healthKitSteps;
                    self.healthManager.saveSteps(stepsDifference)
                    print("Steps Difference is: \(stepsDifference)")
                }
            }
        })
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
