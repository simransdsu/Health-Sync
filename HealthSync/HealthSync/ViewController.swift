//
//  ViewController.swift
//  HealthSync
//
//  Created by Simran Preet S Narang on 10/18/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    let themeColor = UIColor(red: 96/256, green: 191/256, blue: 186/256, alpha: 1)
    var healthManager: HealthManager? =  HealthManager()

    @IBOutlet weak var numberOfStepsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    var totalSteps = 0
    
    let activityManager = CMMotionActivityManager()
    let pedoMeter = CMPedometer()
    
    override func viewWillAppear(animated: Bool) {
        healthManager?.authorizeHealthKit { (authorized,  error) -> Void in
            if authorized {
                self.healthManager?.recentSteps({steps, error in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.numberOfStepsLabel.text = "Loading previous steps"
                        self.totalSteps = Int((steps[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int)!)
                        print(steps[HealthManager.STEP_RECORD_ARRAY])
                        self.numberOfStepsLabel.text = "\(self.totalSteps)"
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
        }    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIColorSetup
        navigationController?.navigationBar.barTintColor = themeColor
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        startButton.backgroundColor = themeColor

        let cal = NSCalendar.currentCalendar()
        let comps = cal.components(NSCalendarUnit.Year , fromDate: NSDate())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.systemTimeZone()
        cal.timeZone = timeZone
        
        //let midnightOfToday = cal.dateFromComponents(comps)!
        
    }
    @IBAction func startStepTrackingAction(sender: AnyObject) {
        if(CMMotionActivityManager.isActivityAvailable()) {
            if(startButton.titleLabel?.text == "Start") {
                startButton.setTitle("Stop", forState: UIControlState.Normal)
                startButton.backgroundColor = UIColor.redColor()
                
                self.pedoMeter.startPedometerUpdatesFromDate(NSDate()) {
                    (data, error) in
                    if error != nil {
                        print("There was an error obtaining pedometer data: \(error)")
                    } else {
                        self.totalSteps += Int(data!.numberOfSteps)
                        dispatch_async(dispatch_get_main_queue()) {
                            self.numberOfStepsLabel.text = "\(self.totalSteps)"
                            //self.distanceLabel.text = "\(self.lengthFormatter.stringFromMeters(data.distance as! Double))"
                        }
                    }
                }
            }
            else {
                startButton.setTitle("Start", forState: UIControlState.Normal)
                startButton.backgroundColor = themeColor
                self.pedoMeter.stopPedometerUpdates()
                
                let destinationVC = self.storyboard!.instantiateViewControllerWithIdentifier("SyncViewController") as! SyncViewController
                destinationVC.totalSteps = Int(self.numberOfStepsLabel.text!)!;
                self.navigationController?.pushViewController(destinationVC, animated: true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

