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
                
            }
            else
            {
                print("HealthKit authorization denied!")
                if error != nil {
                    print("\(error)")
                }
            }
        }
        self.navigationController!.navigationBar.topItem!.title = "Step Counter"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.backgroundColor = themeColor
        startButton.layer.borderColor = UIColor.blackColor().CGColor
        startButton.layer.cornerRadius = 5
        startButton.layer.borderWidth = 0.5
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components(NSCalendarUnit.Year , fromDate: NSDate())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = NSTimeZone.systemTimeZone()
        cal.timeZone = timeZone
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
                        self.totalSteps = Int(data!.numberOfSteps)
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
                if(self.totalSteps != 0) {
                    let alertController = UIAlertController(
                        title: "Sync",
                        message: "Do you want to sync your steps with other devices as well ?",
                        preferredStyle: UIAlertControllerStyle.Alert
                    )
                    
                    let confirmAction = UIAlertAction(
                        title: "YES", style: UIAlertActionStyle.Default) { (action) in
                            let destinationVC = self.storyboard!.instantiateViewControllerWithIdentifier("SyncViewController") as! SyncViewController
                            destinationVC.totalSteps = self.totalSteps;
                            self.navigationController?.pushViewController(destinationVC, animated: true)
                    }
                    
                    let cancelAction = UIAlertAction(
                        title: "NO",
                        style: UIAlertActionStyle.Destructive) { (action) in
                    }
                    alertController.addAction(confirmAction)
                    alertController.addAction(cancelAction)
                    
                    presentViewController(alertController, animated: true, completion: nil)
                }
                    
                else {
                    showAlertView("🚶OOPS!🚶", message: "You need to walk first.", view: self)
                }
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

