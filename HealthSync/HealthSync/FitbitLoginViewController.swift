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
        loginBackBtn.layer.borderWidth = 0.5
        loginBackBtn.layer.borderColor = UIColor.grayColor().CGColor
        loginBackBtn.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: true)
        //        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Fitbit one time authorization.
    @IBAction func loginWithFitbit(sender: AnyObject) {
        
        if (self.loginBackBtn.titleLabel?.text == "Login With Fitbit") {
            
            self.navigationItem.setHidesBackButton(false, animated: true)
            if(isConnectedToNetwork()){
                let fbManager = FitBitManager()
                fbManager.doFitBitOAuth({(result) -> Void in
                    self.loginBackBtn.setTitle("Done", forState: UIControlState.Normal)
                })
            }else{
                showAlertView("No Internet Access", message: "Please Connect to Internet and try again later.", view: self)
            
            }
        } else {
            
            if((self.delegate?.isKindOfClass(SyncAllViewController) == true)) {
                let parentViewController = (self.delegate as! SyncAllViewController)
                parentViewController.syncAll()
            }else if ((self.delegate?.isKindOfClass(SyncViewController) == true)) {
                let parentViewController = (self.delegate as! SyncViewController)
                parentViewController.syncAll()
            }
            self.navigationController?.popViewControllerAnimated(true)
            
        }
    }
    @objc func backActions() {
        self.loginBackBtn.hidden = true;
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
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
