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
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var syncAllButton: UIButton!
    let activitySpinner = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncAllButton.layer.borderWidth = 0.5
        syncAllButton.layer.borderColor = UIColor.grayColor().CGColor
        syncAllButton.layer.cornerRadius = 10
        
        infoLabel.layer.borderColor = UIColor.grayColor().CGColor
        infoLabel.layer.borderWidth = 0.5
        infoLabel.layer.cornerRadius = 5
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
                
                guard  let totalSteps = (steps[HealthManager.TOTAL_STEPS_COUNT_AS_DOUBE] as? Int) else {
                    stopSpinner(self.activitySpinner)
                    showAlertView("Sync Error", message: "Go to Healthkit sources and enable necessary permissions.", view: self)
                    return
                }
                
                let healthKitSteps = Int(totalSteps)
                
                self.fitbitManager.getFitbitSteps({(result)-> Void in
                    guard  let fitbitSteps = result else {
                        stopSpinner(self.activitySpinner)
                        showAlertView("Sync Error", message: "Please try again later.", view: self)
                        return
                    }
                    self.syncSteps(fitbitSteps, healthKitSteps: healthKitSteps)
                })
            }
        })
        
    }
    
    func syncSteps(fitbitSteps:Int , healthKitSteps:Int){
        
        guard healthKitSteps != fitbitSteps else {
            
            showAlertView("Data Synced", message: "Your data is already synced.", view: self)
            stopSpinner(self.activitySpinner)
            return
            
        }
        if(healthKitSteps < fitbitSteps){
            
            let  stepsDifference = (fitbitSteps - healthKitSteps)
            self.healthManager?.saveSteps(stepsDifference)
            
        }else{
            
            let stepsDifference = (healthKitSteps - fitbitSteps)
            self.fitbitManager.syncStepsWithFitbit(stepsDifference, syncSource: "HTOF", completion:
                { (result) -> Void in
                    
                    guard (result != nil) else{
                        stopSpinner(self.activitySpinner)
                        showAlertView("Sync Error", message: "Please try again later.", view: self)
                        return
                    }
                    
                    stopSpinner(self.activitySpinner)
                    showAlertView("Congrats", message: "Your data sync is complete", view: self)
            })
        }
        
    }
    
}