//
//  SyncAllViewController.swift
//  HealthSync
////
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
    
    @IBOutlet weak var syncAllButton: UIButton!
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        syncAllButton.layer.borderWidth = 0.5
        syncAllButton.layer.borderColor = UIColor.grayColor().CGColor
        syncAllButton.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController!.navigationBar.topItem!.title = "Sync All"
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
        
        showSpinner(activitySpinner, forView: self)
        guard isConnectedToNetwork() else{
            showAlertView("No Internet Access", message: "Please Connect to Internet and then try again", view: self)
            stopSpinner(activitySpinner)
            return
        }
        
        healthManager?.recentSteps({steps, error in
            dispatch_async(dispatch_get_main_queue()) {
                if let totalSteps = (steps[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int) {
                    let healthKitSteps = Int(totalSteps)
                    self.fitbitManager.getFitbitSteps({(result)-> Void in
                        if let fitbitSteps = result {
                            self.syncSteps(fitbitSteps, healthKitSteps: healthKitSteps)
                        }
                        stopSpinner(self.activitySpinner)
                        showAlertView("Congrats", message: "Your data sync is complete", view: self)
                    })
                } else {
                    stopSpinner(self.activitySpinner)
                    showAlertView("Sync Error", message: "Please try again", view: self)
                }
            }
        })
        
    }
    
    func syncSteps(fitbitSteps:Int , healthKitSteps:Int){
        
        guard healthKitSteps != fitbitSteps else {
            showAlertView("Data Synced", message: "Your data is already synced.", view: self)
            return
        }
        if(healthKitSteps < fitbitSteps){
            let  stepsDifference = (fitbitSteps - healthKitSteps)
            self.healthManager?.saveSteps(stepsDifference)
        }else {
            let stepsDifference = (healthKitSteps - fitbitSteps)
            self.fitbitManager.syncStepsWithFitbit(stepsDifference,syncSource:"HTOF")
        }
        
    }
    
}