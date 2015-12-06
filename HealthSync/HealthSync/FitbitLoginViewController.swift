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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginWithFitbit(sender: AnyObject) {
        let fbManager = FitBitManager()
        fbManager.doFitBitOAuth({(result) -> Void in
            self.navigationController?.popViewControllerAnimated(true)
        })
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        let parentViewController = (self.delegate as! SyncAllViewController)

        if(self.isMovingFromParentViewController()) {
            if(self.methodStatus == "getProfileData") {
                parentViewController.getProfileData();
            }
        }
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
