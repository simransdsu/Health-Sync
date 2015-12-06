//
//  FitbitLoginViewController.swift
//  HealthSync
//
//  Created by Simran Preet S Narang on 12/6/15.
//  Copyright © 2015 SwiftStudio. All rights reserved.
//

import UIKit

class FitbitLoginViewController: UIViewController {
    
    var delegate: AnyObject?
    var methodStatus: String?

    @IBOutlet weak var loginBackBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWithFitbit(sender: AnyObject) {
        if (self.loginBackBtn.titleLabel?.text == "Login With Fitbit") {
            let fbManager = FitBitManager()
            fbManager.doFitBitOAuth({(result) -> Void in
                
                self.loginBackBtn.setTitle("Done", forState: UIControlState.Normal)
            })
        } else {
            
            let parentViewController = (self.delegate as! SyncAllViewController)
            parentViewController.getProfileData();
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        

        
    }
    
    override func viewDidDisappear(animated: Bool) {
//        if(self.isMovingFromParentViewController()) {
//            if(self.methodStatus == "getProfileData") {
//                let parentViewController = (self.delegate as! SyncAllViewController)
//                parentViewController.getProfileData();
//            }
//        }
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
