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
    
    @IBOutlet weak var syncButton: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncButton.layer.borderWidth = 0.5
        syncButton.layer.borderColor = UIColor.grayColor().CGColor
        syncButton.layer.cornerRadius = 10
        
        infoLabel.layer.borderColor = UIColor.grayColor().CGColor
        infoLabel.layer.borderWidth = 0.5
        infoLabel.layer.cornerRadius = 5
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    @IBAction func syncWithFitbit(sender: AnyObject) {
        
        
        let accessToken = FitBitCredentials.sharedInstance.fitBitValueForKey("accessToken")
        if accessToken == nil || accessToken!.characters.count == 0 {
            let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("FitbitLoginViewController") as! FitbitLoginViewController
            secondViewController.delegate = self
            secondViewController.methodStatus = "syncAll"
            self.navigationController?.pushViewController(secondViewController, animated: true)
        } else {
            if(totalSteps > 0) {
                self.syncAll()
            }
        }
    }
    
    func syncAll() {
        
        guard isConnectedToNetwork() else{
            showAlertView("No Internet Access", message: "Please connect to Internet and try again ", view: self)
            return
        }
        
        let fitbitManager = FitBitManager()
        
        
        fitbitManager.syncStepsWithFitbit(totalSteps, syncSource: "HSTOF", completion:
            { (result) -> Void in
                
                guard (result != nil) else{
                    showAlertView("Sync Error", message: "Please try again later.", view: self)
                    return
                }
                
                showAlertView("Congrats", message: "Your data sync is complete", view: self)
                self.totalSteps = 0;
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
