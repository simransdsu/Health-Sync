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

            if(self.delegate?.isKindOfClass(ProfileViewController) == true) {
                let parentViewController = (self.delegate as! ProfileViewController)
                parentViewController.getProfileData()
            } else if((self.delegate?.isKindOfClass(SyncAllViewController) == true)) {
                let parentViewController = (self.delegate as! SyncAllViewController)
                parentViewController.syncAll()
            }

        
            self.navigationController?.popViewControllerAnimated(true)
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
