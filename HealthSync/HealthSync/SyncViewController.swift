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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        syncButton.layer.borderWidth = 0.5
        syncButton.layer.borderColor = UIColor.grayColor().CGColor
        syncButton.layer.cornerRadius = 10
        
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
            self.syncAll()
        }
    }
    
    func syncAll() {
        
        guard Util.isConnectedToNetwork() else{
            Util.showAlertView("No Internet Access", message: "Please connect to Internet and try again ", view: self)
            return
        }
        
        let fitbitManager = FitBitManager()
        fitbitManager.syncStepsWithFitbit(totalSteps)
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
